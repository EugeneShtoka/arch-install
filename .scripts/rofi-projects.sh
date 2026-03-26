#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9'

command=$(. $SCRIPTS_PATH/projects-list.sh | $SCRIPTS_PATH/rofi-run.sh -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
if [[ -n $command ]]; then
    wezterm cli spawn -- zsh -ic $command 2>/dev/null || wezterm start -- zsh -ic $command
    (sleep 2 && $SCRIPTS_PATH/wezterm-tabs-update.sh) &
    disown
fi
