#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-narrow-short"

source /home/eugene/.env

modes=("sleep" "reboot" "shutdown")

selected=$(printf "%s\n" "${modes[@]}" | \
  $SCRIPTS_PATH/rofi-run.sh -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "power" -i)

[[ -z "$selected" ]] && exit

case $selected in
    sleep)    systemctl suspend ;;
    reboot)   systemctl reboot ;;
    shutdown) shutdown now ;;
esac
