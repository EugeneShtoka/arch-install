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

ctx=0
[[ -f /tmp/claude-context-switch ]] && ctx=$(< /tmp/claude-context-switch)

throttled=$(( now - last < THROTTLE_SECS ))
ctx_switched=$(( ctx > last ))

if (( !throttled || ctx_switched )); then
    notify-send "$title" "$body"
fi

if (( !throttled )); then
    paplay "$sound"
fi
