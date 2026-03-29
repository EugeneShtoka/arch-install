#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-narrow"

source /home/eugene/.env

modes=("external" "laptop" "dual")

selected=$(printf "%s\n" "${modes[@]}" | \
  $SCRIPTS_PATH/rofi-run.sh -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "monitor" -i)

[[ -z "$selected" ]] && exit

$SCRIPTS_PATH/monitor-setup.sh "$selected"
