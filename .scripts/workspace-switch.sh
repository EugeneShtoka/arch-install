#!/bin/zsh

ws=$(i3-msg -t get_workspaces | jq -r '.[].name' | rofi -dmenu -p "workspace")
[[ -n "$ws" ]] && i3-msg workspace "$ws"
