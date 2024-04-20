#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-10'

command=$(. $SCRIPTS_PATH/functions-list.sh | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
zsh -ic $command