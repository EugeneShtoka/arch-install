#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-3"
theme='style-10'

command=$(. $SCRIPTS_PATH/functions-list.sh | rofi -theme ${dir}/${theme}.rasi -dmenu -mathcing fuzzy)
zsh -ic $command