#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9'

projects=$(. $SCRIPTS_PATH/projects-list.sh)

selected=$(echo "$projects" | cut -d'|' -f1 | $SCRIPTS_PATH/rofi-run.sh -theme ${rofi_dir}/${theme}.rasi -dmenu -matching prefix)
[[ -z $selected ]] && exit

path=$(echo "$projects" | awk -F'|' -v name="$selected" '$1 == name {print $2}')
[[ -z $path ]] && exit

$SCRIPTS_PATH/nvim-open-project.sh "$selected" "$path"
