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

if (( now - last >= THROTTLE_SECS )); then
    notify-send "$title" "$body"
    paplay "$sound"
    exit 0
fi

# Within throttle window: show popup silently if user switched context since last notification
ctx=0
[[ -f /tmp/claude-context-switch ]] && ctx=$(< /tmp/claude-context-switch)
(( ctx > last )) && notify-send "$title" "$body"
