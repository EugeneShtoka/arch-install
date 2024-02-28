#!/bin/zsh

# Volume information (assumes PulseAudio)
source $SCRIPTS_PATH/get-volume-level.sh
source $SCRIPTS_PATH/get-battery-icon.sh

echo "`date` switch-headphones" >> $LOG_PATH
volumeLevel="$(printf '\uf028\n') $(get-volume-level)%"

blStatus=$(bluetoothctl info $HEADPHONES_MAC_ADDR)

if ([[ "$blStatus" == *"Device $HEADPHONES_MAC_ADDR not available"* ]]); then
    notify-send "Headphones not available" "Volume: $volumeLevel" -i volume-high  
else
    isConnected=$(echo $blStatus | grep Connected | awk '{print $2}')

    if [[ "$isConnected" == "yes" ]]; then
        name=$(echo $blStatus | grep -oP '(?<=Name: ).*' )
        battery_level=$(echo $blStatus | grep -oP '(?<=Battery Percentage: ).*' | awk '{print $2}' | tr -d \(\))
        message="$(get_battery_icon $battery_level) $battery_level% $volumeLevel"
        echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
        notify-send "$name disconnected" "$message" -i headphones-disconnect 
    else
        echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
        sleep 2
        blStatus=$(bluetoothctl info $HEADPHONES_MAC_ADDR)
        echo "$blStatus"
        name=$(echo $blStatus | grep -oP '(?<=Name: ).*' )
        battery_level=$(echo $blStatus | grep -oP '(?<=Battery Percentage: ).*' | awk '{print $2}' | tr -d \(\))
        message="$(get_battery_icon $battery_level) $battery_level% $volumeLevel"
        notify-send "$name connected" "$message" -i headphones
    fi
fi
