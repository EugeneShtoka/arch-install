#!/bin/zsh
url=$(/usr/bin/xclip -o -selection clipboard | grep -oE 'https?://[^[:space:]]+' | head -1)
[[ -n "$url" ]] && xdg-open "$url"
