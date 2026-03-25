#!/bin/zsh

# If notifications are currently displayed they aren't in history yet — close them first
displayed=$(dunstctl count displayed 2>/dev/null)
[[ "$displayed" -gt 0 ]] && dunstctl close-all && sleep 0.1

read -r summary body < <(dunstctl history | tr -d '\000-\037' | jq -r '
  .data[0] | sort_by(.timestamp.data) | last |
  [(.summary.data // ""), (.body.data // "")] | @tsv
')

[[ -z "$summary" && -z "$body" ]] && exit

# Temporarily change global origin to center (section-aware)
sed -i '/^\[global\]/,/^\[/{s/^\s*origin = .*/    origin = center/}' ~/.config/dunst/dunstrc
dunstctl reload 2>/dev/null

notify-send -a "pinned" -t 0 "$summary" "$body"

# Restore
sed -i '/^\[global\]/,/^\[/{s/^\s*origin = .*/    origin = top-right/}' ~/.config/dunst/dunstrc
dunstctl reload 2>/dev/null
