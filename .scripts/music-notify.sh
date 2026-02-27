#!/bin/zsh

dbus-monitor --session "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/mpris/MediaPlayer2'" 2>/dev/null |
while read -r line; do
  if echo "$line" | grep -q "Metadata"; then
    sleep 0.3
    artist=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null | grep -A2 "xesam:artist" | grep "string" | head -1 | sed 's/.*string "//;s/"//')
    title=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null | grep -A1 "xesam:title" | grep "string" | head -1 | sed 's/.*string "//;s/"//')

    if [[ -n "$title" ]]; then
      if [[ -n "$artist" ]]; then
        notify-send "$artist" "<span font='20px'>$title</span>" -r 101029
      else
        notify-send "Now Playing" "<span font='20px'>$title</span>" -r 101029
      fi
    fi
  fi
done
