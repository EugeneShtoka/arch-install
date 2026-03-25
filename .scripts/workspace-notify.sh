#!/bin/zsh

source $SCRIPTS_PATH/notify-lib.sh

while true; do
    i3-msg -t subscribe '["workspace"]' | while IFS= read -r line; do
        ws=$(echo "$line" | jq -r 'if .change == "focus" then .current.name else empty end')
        [[ -n "$ws" ]] && notify_send -r 9900 -t 1500 -a "system-notify" "Workspace $ws"
    done
    sleep 1
done
