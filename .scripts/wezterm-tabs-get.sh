#!/bin/zsh

cache="$HOME/.cache/wezterm-tabs.json"
if [[ -f "$cache" && $(( $(date +%s) - $(stat -c %Y "$cache") )) -lt 90 ]]; then
  cat "$cache"
else
  wezterm cli list --format json 2>/dev/null || echo '[]'
fi
