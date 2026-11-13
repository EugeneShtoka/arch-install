#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9'

# Show display names, run the alias behind the picked one
typeset -A games
while IFS=$'\t' read -r name title; do
  games[$title]=$name
done < <(. $SCRIPTS_PATH/games-list.sh)

title=$(print -l ${(k)games} | $SCRIPTS_PATH/rofi-freq.sh games -theme ${dir}/${theme}.rasi -matching prefix)
[[ -n $title ]] || exit 1
zsh -ic ${games[$title]}
