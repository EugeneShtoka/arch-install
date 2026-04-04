#!/bin/zsh
# Focus a native app by WM_CLASS, or launch it
# Usage: app-focus-or-launch.sh "WM_CLASS" cmd [args...]

WM_CLASS="$1"
shift

con_id=$(i3-msg -t get_tree | jq -r --arg c "$WM_CLASS" '
  [.. | objects | select(.window != null) | select(.window_properties.class == $c)] | .[0].id // empty
')

if [[ -n "$con_id" ]]; then
  i3-msg "[con_id=$con_id] focus"
else
  setsid "$@" &>/dev/null
fi
