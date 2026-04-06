#!/bin/zsh

if [[ $1 == --window ]]; then
    setsid wezterm start --tab-title "Browser" -- yazi &>/dev/null
else
    ~/.scripts/wezterm-focus-or-launch.sh "Browser" yazi
fi
