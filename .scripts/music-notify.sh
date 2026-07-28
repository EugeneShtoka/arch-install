#!/bin/zsh
# Show "now playing" notifications for both playback backends:
#   - MPD   : music played through the rmpc client (polled via `mpc idle`)
#   - mpv   : videos/podcasts played via yt-play.sh (watched via MPRIS/dbus)
# Both listeners run concurrently; each dedupes so only real track changes fire.

# --- MPD listener ---
mpd_listen() {
  local last=""
  while song=$(mpc current -f '%file%' 2>/dev/null); do
    if [[ -n "$song" && "$song" != "$last" ]]; then
      last="$song"
      $SCRIPTS_PATH/music-status-show.sh mpd
    fi
    mpc idle player >/dev/null 2>&1 || sleep 1
  done
}

# --- mpv (MPRIS) listener ---
mpv_listen() {
  local last=""
  dbus-monitor --session "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/mpris/MediaPlayer2'" 2>/dev/null |
  while read -r line; do
    if echo "$line" | grep -q "Metadata"; then
      sleep 0.3
      title=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.mpv /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null | grep -A1 '"xesam:title"' | grep 'string "' | tail -1 | sed 's/.*string "//;s/"//')
      if [[ -n "$title" && "$title" != "$last" ]]; then
        last="$title"
        $SCRIPTS_PATH/music-status-show.sh mpv
      fi
    fi
  done
}

mpd_listen &
mpv_listen &
wait
