#!/bin/zsh

USR_HOME=/home/eugene
source $USR_HOME/.env

source $SCRIPTS_PATH/root-notify-send.sh
source $SCRIPTS_PATH/battery.sh

get_battery_info
echo $reply[1] $reply[2]
root-notify-send "Charging $battery_level%" -i $ICONS_PATH/plug.png -r 101029