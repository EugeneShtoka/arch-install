#!/bin/zsh
# Shared app display name mapping — single source of truth.
# Keys are X11 window classes (used by app-switch/app-kill for non-wezterm
# windows); values are the friendly names shown in rofi.
# Consumers:
#   - APP_NAMES_JQ            : JSON form for jq calls (--argjson names ...)
#   - app_display_name <key>  : shell lookup (falls back to the key itself)

typeset -A APP_NAMES=(
  "Vivaldi-stable" "Web browser"
  "NeoMutt"        "Email"
  "Yazi"           "File browser"
  "ticker"         "Stocks"
  "kith"           "Messenger"
  "Element"        "Messenger (V)"
)

# Derive the JSON form from the map above so the mapping is defined only once.
APP_NAMES_JQ=$(jq -n '$ARGS.positional | [range(0; length; 2) as $i | {(.[$i]): .[$i+1]}] | add' --args "${(@kv)APP_NAMES}")

app_display_name() {
  print -r -- "${APP_NAMES[$1]:-$1}"
}
