#!/bin/zsh
# Usage: claude-notify.sh <title> <body> <sound>
# Throttles: skips if <15s since last alert

THROTTLE_SECS=15
THROTTLE_FILE=/tmp/claude-notify-last${PWD//\//_}

title=$1
body=$2
sound=$3

now=$(date +%s)

if [[ -f $THROTTLE_FILE ]]; then
    last=$(< $THROTTLE_FILE)
    if (( now - last < THROTTLE_SECS )); then
        echo $now > $THROTTLE_FILE
        exit 0
    fi
fi

echo $now > $THROTTLE_FILE
notify-send "$title" "$body"
paplay "$sound"
