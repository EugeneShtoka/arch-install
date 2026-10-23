#!/usr/bin/env bash
# Download the latest kith release from GitHub and install it.
#
#   kith-update.sh            install the latest release if it is newer than what's installed
#   kith-update.sh --force    install it even if it isn't (e.g. replacing a newer dev build)
#   kith-update.sh v0.1.2     install a specific tag
#
# Installs kith, kithd, kith-mcp (and kith-signal on Linux) into $BINDIR
# (default ~/.local/bin), installs the systemd user units if they are missing,
# and restarts every running kithd unit — daemon and clients must match.
set -euo pipefail

REPO=EugeneShtoka/kith
BINDIR=${BINDIR:-$HOME/.local/bin}
UNITDIR=${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user

force=0 tag=""
for a in "$@"; do
  case $a in
    -f|--force) force=1 ;;
    -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    v*) tag=$a ;;
    *) echo "unknown argument: $a" >&2; exit 2 ;;
  esac
done

case $(uname -s) in Linux) os=linux ;; Darwin) os=darwin ;; FreeBSD) os=freebsd ;;
  *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;; esac
case $(uname -m) in x86_64|amd64) arch=amd64 ;; aarch64|arm64) arch=arm64 ;;
  *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;; esac

if [[ -z $tag ]]; then
  tag=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" |
    sed -n 's/^ *"tag_name": *"\([^"]*\)".*/\1/p')
  [[ -n $tag ]] || { echo "could not determine the latest release" >&2; exit 1; }
fi
ver=${tag#v}

# Installed version, e.g. "v0.1.0" or a dev pseudo-version "v0.1.1-0.2026...-88cc1ec33293".
cur=""
[[ -x $BINDIR/kith ]] && cur=$("$BINDIR/kith" --version 2>/dev/null | awk 'NR==1{print $2}') || true
cur=${cur#v}

# A pseudo-version X-0.<date>-<sha> is a dev build *before* release X.
newer() {
  local base=${cur%%-*}
  [[ -z $cur ]] && return 0
  [[ $ver == "$base" ]] && { [[ $cur == *-* ]]; return; }
  [[ $(printf '%s\n%s\n' "$base" "$ver" | sort -V | tail -n1) == "$ver" ]]
}

echo "==> installed: ${cur:-none}   release: $ver"
if (( ! force )) && ! newer; then
  echo "==> already up to date (use --force to reinstall $tag)"
  exit 0
fi

tmp=$(mktemp -d "${TMPDIR:-/tmp}/kith-update.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
archive="kith_${ver}_${os}_${arch}.tar.gz"
base="https://github.com/$REPO/releases/download/$tag"

echo "==> downloading $archive"
curl -fsSL -o "$tmp/$archive" "$base/$archive"
curl -fsSL -o "$tmp/checksums.txt" "$base/checksums.txt"

want=$(awk -v f="$archive" '$2==f{print $1}' "$tmp/checksums.txt")
[[ -n $want ]] || { echo "$archive is not in checksums.txt" >&2; exit 1; }
if command -v sha256sum >/dev/null; then got=$(sha256sum "$tmp/$archive" | awk '{print $1}')
else got=$(shasum -a 256 "$tmp/$archive" | awk '{print $1}'); fi
[[ $got == "$want" ]] || { echo "checksum mismatch for $archive" >&2; exit 1; }
echo "==> checksum ok"

mkdir "$tmp/x"
tar -xzf "$tmp/$archive" -C "$tmp/x"

mkdir -p "$BINDIR"
for b in kith kithd kith-mcp kith-signal; do
  [[ -f $tmp/x/$b ]] || continue
  install -m755 "$tmp/x/$b" "$BINDIR/$b"
  echo "==> $BINDIR/$b"
done

[[ $os == linux ]] && command -v systemctl >/dev/null || {
  echo "==> done; restart kithd yourself so it runs the new binary"
  exit 0
}

# The archive's units point at %h/.local/bin; only add them where none exist yet.
reload=0
for u in kithd.service kithd@.service; do
  if [[ ! -e $UNITDIR/$u && -f $tmp/x/packaging/systemd/$u ]]; then
    install -Dm644 "$tmp/x/packaging/systemd/$u" "$UNITDIR/$u"
    echo "==> unit $UNITDIR/$u"
    reload=1
  fi
done
(( reload )) && systemctl --user daemon-reload

units=$(systemctl --user list-units --state=active --plain --no-legend 'kithd.service' 'kithd@*.service' | awk '{print $1}')
if [[ -z $units ]]; then
  echo "==> no kithd running; start it with: systemctl --user enable --now kithd.service"
  exit 0
fi
for u in $units; do
  systemctl --user restart "$u"
  echo "==> restarted $u"
done
echo "==> kith $ver installed; restart any open kith clients"
