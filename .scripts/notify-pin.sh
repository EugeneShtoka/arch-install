#!/bin/zsh

latest=$(dunstctl history | tr -d '\000-\037' | jq -r '.data[0] | sort_by(.timestamp.data) | last')
summary=$(echo "$latest" | jq -r '.summary.data // ""')
body=$(echo "$latest" | jq -r '.body.data // ""')

[[ -z "$summary" && -z "$body" ]] && exit

notify-send -a "pinned" -t 0 "$summary" "$body"
