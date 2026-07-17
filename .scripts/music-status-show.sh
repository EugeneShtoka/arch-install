#!/bin/zsh

source $SCRIPTS_PATH/notify-lib.sh

metadata=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.mpv /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null)

artist=$(echo "$metadata" | grep -A2 '"xesam:artist"' | grep -v 'xesam:artist' | grep 'string "' | head -1 | sed 's/.*string "//;s/"//')
title=$(echo "$metadata" | grep -A1 '"xesam:title"' | grep -v 'xesam:title' | grep 'string "' | head -1 | sed 's/.*string "//;s/"//')

# Skip notification when title is a raw URL or bare YouTube video ID (watch?v=...)
if [[ -n "$title" ]] && [[ "$title" != http://* ]] && [[ "$title" != https://* ]] && [[ "$title" != watch\?v=* ]]; then
  if [[ -n "$artist" ]]; then
    notify_send "$artist" "<span font='20px'>$title</span>" -r 101029 -a "system-notify"
  else
    notify_send "Now Playing" "<span font='20px'>$title</span>" -r 101029 -a "system-notify"
  fi
fi
