#!/bin/zsh
# Show a "now playing" notification for the given source.
# Usage: music-status-show.sh [mpd|mpv]   (default: mpd)

source $SCRIPTS_PATH/notify-lib.sh

source_kind="${1:-mpd}"

if [[ "$source_kind" == "mpv" ]]; then
  # mpv exposes MPRIS via the mpv-mpris plugin. Query it directly so other
  # MPRIS players (e.g. the browser) are ignored.
  metadata=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.mpv /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null)
  [[ -z "$metadata" ]] && exit 0
  artist=$(echo "$metadata" | grep -A2 '"xesam:artist"' | grep -v 'xesam:artist' | grep 'string "' | head -1 | sed 's/.*string "//;s/"//')
  title=$(echo "$metadata" | grep -A1 '"xesam:title"' | grep -v 'xesam:title' | grep 'string "' | head -1 | sed 's/.*string "//;s/"//')
else
  # MPD (music played through the rmpc client).
  [[ "$(mpc status '%state%' 2>/dev/null)" == "playing" ]] || exit 0
  artist=$(mpc current -f '%artist%' 2>/dev/null)
  title=$(mpc current -f '%title%' 2>/dev/null)
fi

# Skip notification when title is a raw URL or bare YouTube video ID (watch?v=...)
if [[ -n "$title" ]] && [[ "$title" != http://* ]] && [[ "$title" != https://* ]] && [[ "$title" != watch\?v=* ]]; then
  if [[ -n "$artist" ]]; then
    notify_send "$artist" "<span font='20px'>$title</span>" -r 101029 -a "system-notify"
  else
    notify_send "Now Playing" "<span font='20px'>$title</span>" -r 101029 -a "system-notify"
  fi
fi
