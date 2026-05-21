#!/bin/zsh
# Usage: claude-notify.sh <title> <body> <sound>
# Throttles: skips if <15s since last alert

THROTTLE_SECS=15
THROTTLE_FILE=/tmp/claude-notify-last${PWD//\//_}

title=$1
body=$2
sound=$3

now=$(date +%s)

last=0
[[ -f $THROTTLE_FILE ]] && last=$(< $THROTTLE_FILE)
echo $now > $THROTTLE_FILE
(( now - last < THROTTLE_SECS )) && exit 0
notify-send "$title" "$body"
paplay "$sound"
