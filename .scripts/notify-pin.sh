#!/bin/zsh

read -r summary body < <(dunstctl history | tr -d '\000-\037' | jq -r '
  .data[0] | sort_by(.timestamp.data) | last |
  [(.summary.data // ""), (.body.data // "")] | @tsv
')

[[ -z "$summary" && -z "$body" ]] && exit

notify-send -a "pinned" -t 0 "$summary" "$body"
