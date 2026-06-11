#!/bin/zsh

podcast=0
url=""

for arg in "$@"; do
  case "$arg" in
    -p|--podcast) podcast=1 ;;
    -c|--clipboard) url=$(xclip -o -selection clipboard) ;;
    -*) print "Usage: ${0:t} [-p|--podcast] [-c|--clipboard] [<url>]" >&2; exit 1 ;;
    *) url="$arg" ;;
  esac
done

if [[ -z "$url" ]]; then
  print "Usage: ${0:t} [-p|--podcast] [-c|--clipboard] [<url>]" >&2
  exit 1
fi

tmpdir=$(mktemp -d /tmp/yt-play.XXXXXX)

if (( podcast )); then
  yt-dlp -x --audio-format mp3 \
    --sponsorblock-remove all \
    -o "$tmpdir/%(title)s.%(ext)s" \
    "$url"
else
  yt-dlp \
    --sponsorblock-remove all \
    -o "$tmpdir/%(title)s.%(ext)s" \
    "$url"
fi

files=("$tmpdir"/*(N))
if (( ${#files} == 0 )); then
  print "Download failed or produced no files." >&2
  exit 1
fi

vlc "${files[1]}"
