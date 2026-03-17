#!/bin/zsh

ws=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused) | .name')
dunstify -r 9900 -t 2000 "Workspace $ws"
