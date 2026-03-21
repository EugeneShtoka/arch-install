#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9-columns'

command=$(. $SCRIPTS_PATH/functions-list.sh | $SCRIPTS_PATH/rofi-run.sh -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
zsh -ic $command
