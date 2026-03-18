#!/bin/zsh

ws=$1
echo "$ws" > /tmp/workspace-current
i3-msg workspace "$ws"
[[ "$(cat /tmp/workspace-current)" == "$ws" ]] || exit 0
dunstctl close 9900 2>/dev/null
notify-send -r 9900 -t 1500 "Workspace $ws"
