#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9'

command=$(. $SCRIPTS_PATH/projects-list.sh | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
alacritty -e zsh -ic $command
