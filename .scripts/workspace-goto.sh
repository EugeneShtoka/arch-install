#!/bin/zsh

ws=$1
i3-msg workspace "$ws"
notify-send -r 9900 -t 1500 "Workspace $ws"
