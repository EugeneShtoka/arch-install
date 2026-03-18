#!/bin/zsh

ws=$1
i3-msg workspace "$ws"
sleep 0.3
dunstctl close 9900 2>/dev/null
notify-send -r 9900 -t 1500 "Workspace $ws"
