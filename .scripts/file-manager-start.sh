#!/bin/zsh

if [[ $1 == --window ]]; then
    setsid wezterm start -- yazi &>/dev/null
else
    ~/.scripts/wezterm-focus-or-launch.sh "File browser" yazi
fi
