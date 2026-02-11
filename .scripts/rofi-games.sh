#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9'

command=$(. $SCRIPTS_PATH/games-list.sh | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
zsh -ic $command
