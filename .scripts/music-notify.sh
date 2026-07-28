#!/bin/zsh
# Watch MPD for song changes and show a "now playing" notification.
# Uses `mpc idleloop player` (fires on play/pause/seek/song-change); we dedupe
# on the current file so only actual track changes notify.

last=""
while song=$(mpc current -f '%file%' 2>/dev/null); do
  if [[ -n "$song" && "$song" != "$last" ]]; then
    last="$song"
    $SCRIPTS_PATH/music-status-show.sh
  fi
  # Block until the next player event, then loop.
  mpc idle player >/dev/null 2>&1 || sleep 1
done
