#!/bin/zsh

USR_HOME=/home/eugene
source $USR_HOME/.env

source $SCRIPTS_PATH/root-notify-send.sh

power_info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
battery_level=$(echo "$power_info" | grep percentage | awk '{print $2}' | tr -d %)
state=$(echo "$power_info" | grep state | awk '{print $2}')

root-notify-send "Charging $battery_level%" -i $ICONS_PATH/plug.png -r 101029