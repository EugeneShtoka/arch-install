#!/bin/zsh

read -r summary body < <(dunstctl history | tr -d '\000-\037' | jq -r '
  .data[0] | sort_by(.timestamp.data) | last |
  [(.summary.data // ""), (.body.data // "")] | @tsv
')

[[ -z "$summary" && -z "$body" ]] && exit

sed -i 's/^    origin = top-right/    origin = center/' ~/.config/dunst/dunstrc
dunstctl reload 2>/dev/null
notify-send -a "pinned" -t 0 "$summary" "$body"
sed -i 's/^    origin = center/    origin = top-right/' ~/.config/dunst/dunstrc
dunstctl reload 2>/dev/null
