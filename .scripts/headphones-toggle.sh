#!/bin/zsh

source $SCRIPTS_PATH/volume.sh
source $SCRIPTS_PATH/battery.sh
source $SCRIPTS_PATH/bluetooth.sh

echo "`date` switch-headphones" >> $LOG_PATH
blStatus=$(bluetooth_status)

if ([[ "$(bluetooth_status)" == *"Device $HEADPHONES_MAC_ADDR not available"* ]]); then
    dunstify "Headphones not available" "$(get_audio_status)" -i headphones-disconnect -r 101047
else
    if [[ "$(is_bluetooth_connected)" == "yes" ]]; then
        show-headphones-message "disconnected"
        echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
    else
        echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
        sleep 2
        show-headphones-message "connected"
    fi
fi
