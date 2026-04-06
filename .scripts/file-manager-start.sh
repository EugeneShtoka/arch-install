#!/bin/zsh

if [[ $1 == --window ]]; then
    setsid wezterm start --tab-title "Yazi" -- yazi &>/dev/null
else
    ~/.scripts/wezterm-focus-or-launch.sh "Yazi" yazi
fi
