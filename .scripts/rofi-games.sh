#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9'

command=$(. $SCRIPTS_PATH/games-list.sh | $SCRIPTS_PATH/rofi-freq.sh games -theme ${dir}/${theme}.rasi -matching prefix)
zsh -ic $command
