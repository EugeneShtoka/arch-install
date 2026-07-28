#!/bin/zsh
# Convert VLC/XSPF playlists under $MUSIC_PATH into MPD .m3u playlists.
# Output goes to MPD's playlist_directory (~/.config/mpd/playlists) with paths
# relative to the music_directory, then triggers `mpc lsplaylists` refresh.

music_dir="${MUSIC_PATH:-$HOME/Music}"
playlist_dir="$HOME/.config/mpd/playlists"

mkdir -p "$playlist_dir"

python3 - "$music_dir" "$playlist_dir" <<'PY'
import sys, os, glob
from urllib.parse import unquote, urlparse
import xml.etree.ElementTree as ET

music_dir, playlist_dir = sys.argv[1], sys.argv[2]
music_dir = os.path.realpath(music_dir)
ns = {"x": "http://xspf.org/ns/0/"}

converted = 0
for xspf in glob.glob(os.path.join(music_dir, "**", "*.xspf"), recursive=True):
    try:
        tree = ET.parse(xspf)
    except ET.ParseError as e:
        print(f"skip (parse error): {xspf} -- {e}")
        continue

    rels = []
    for loc in tree.getroot().iterfind(".//x:track/x:location", ns):
        if not loc.text:
            continue
        path = unquote(urlparse(loc.text.strip()).path)
        try:
            rel = os.path.relpath(path, music_dir)
        except ValueError:
            rel = path
        if rel.startswith(".."):
            # Outside the music directory -- keep absolute so MPD can still find it.
            rel = path
        rels.append(rel)

    if not rels:
        print(f"skip (no tracks): {xspf}")
        continue

    name = os.path.splitext(os.path.basename(xspf))[0]
    out = os.path.join(playlist_dir, name + ".m3u")
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(rels) + "\n")
    converted += 1
    print(f"{name}.m3u  ({len(rels)} tracks)")

print(f"\nConverted {converted} playlist(s) -> {playlist_dir}")
PY

# Refresh MPD's view of stored playlists (no-op if mpd is down).
mpc -q lsplaylists >/dev/null 2>&1
