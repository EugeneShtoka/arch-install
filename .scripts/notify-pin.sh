#!/bin/zsh

latest=$(dunstctl history | jq -r '.data[0][0]')
summary=$(echo "$latest" | jq -r '.summary.data // ""')
body=$(echo "$latest" | jq -r '.body.data // ""')

[[ -z "$summary" && -z "$body" ]] && exit

notify-send -a "pinned" -t 0 "$summary" "$body"
