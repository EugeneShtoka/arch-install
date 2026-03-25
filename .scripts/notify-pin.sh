#!/bin/zsh

# If notifications are currently displayed they aren't in history yet — close them first
displayed=$(dunstctl count displayed 2>/dev/null)
[[ "$displayed" -gt 0 ]] && dunstctl close-all && sleep 0.1

read -r summary body < <(dunstctl history | tr -d '\000-\037' | jq -r '
  .data[0] | sort_by(.timestamp.data) | last |
  [(.summary.data // ""), (.body.data // "")] | @tsv
')

[[ -z "$summary" && -z "$body" ]] && exit

notify-send -t 0 "$summary" "$body"
