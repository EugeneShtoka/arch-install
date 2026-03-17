#!/bin/zsh

i3-msg -t subscribe '["workspace"]' | while IFS= read -r line; do
    ws=$(echo "$line" | jq -r 'if .change == "focus" then .current.name else empty end')
    [[ -n "$ws" ]] && dunstify -r 9900 -t 1500 "Workspace $ws"
done
