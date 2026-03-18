#!/bin/zsh

ws=$1
i3-msg workspace "$ws"
dunstctl close 9900 2>/dev/null
sleep 0.3
notify-send -r 9900 -t 1500 "Workspace $ws [v2]"
