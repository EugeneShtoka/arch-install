#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-wide"

ws_list=$(i3-msg -t get_tree | jq -r '
  [.. | objects | select(.type == "workspace") | select(.name != "__i3_scratch")] |
  sort_by(.name | try tonumber catch .) |
  .[] |
  {
    name: .name,
    apps: ([.. | objects | select(.window != null) | .window_properties.class] | unique | join("  "))
  } |
  if .apps == "" then .name else "\(.name) : \(.apps)" end
')

ws=$(echo "$ws_list" | rofi -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "workspace" -matching prefix)
[[ -n "$ws" ]] && i3-msg workspace "$(echo "$ws" | awk '{print $1}')"
