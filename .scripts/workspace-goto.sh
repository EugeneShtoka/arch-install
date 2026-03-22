#!/bin/zsh

source $SCRIPTS_PATH/notify-lib.sh

ws=$1
i3-msg workspace "$ws"
dunstctl close 9900 2>/dev/null
notify-send -r 9900 -t 1500 "Workspace $ws" 
