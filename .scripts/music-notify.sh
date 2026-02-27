#!/bin/zsh

dbus-monitor --session "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/mpris/MediaPlayer2'" 2>/dev/null |
while read -r line; do
  if echo "$line" | grep -q "Metadata"; then
    sleep 0.3
    $SCRIPTS_PATH/music-status-show.sh
  fi
done
