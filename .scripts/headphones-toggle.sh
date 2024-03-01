#!/bin/zsh

# Volume information (assumes PulseAudio)
source $SCRIPTS_PATH/volume.sh
source $SCRIPTS_PATH/battery.sh

echo "`date` switch-headphones" >> $LOG_PATH
volumeLevel="$(printf '\uf028\n') $(get-volume-level)%"



if ([[ "$(bluetooth_status)" == *"Device $HEADPHONES_MAC_ADDR not available"* ]]); then
    notify-send "Headphones not available" "$(get_audio_status)" -i headphones-disconnect  
else
    isConnected=$(echo $blStatus | grep Connected | awk '{print $2}')

    if [[ "$isConnected" == "yes" ]]; then
        show-headphones-message "disconnected"
        echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
    else
        echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
        sleep 2
        show-headphones-message "connected"
    fi
fi
