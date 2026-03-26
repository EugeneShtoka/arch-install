#!/bin/zsh

cache_file="$HOME/.cache/wezterm-tabs.json"
tmp_file="${cache_file}.tmp"

wezterm cli list --format json 2>/dev/null > "$tmp_file" && mv "$tmp_file" "$cache_file"
