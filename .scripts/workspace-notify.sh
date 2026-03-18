#!/bin/zsh

while true; do
    pending_pid=""
    i3-msg -t subscribe '["workspace"]' | while IFS= read -r line; do
        ws=$(echo "$line" | jq -r 'if .change == "focus" then .current.name else empty end')
        [[ -n "$ws" ]] || continue
        [[ -n "$pending_pid" ]] && kill "$pending_pid" 2>/dev/null
        (sleep 0.15; dunstify -r 9900 -t 1500 "Workspace $ws") &
        pending_pid=$!
    done
    sleep 1
done
