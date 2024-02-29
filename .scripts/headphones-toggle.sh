#!/bin/zsh

# Volume information (assumes PulseAudio)
source $SCRIPTS_PATH/volume.sh
source $SCRIPTS_PATH/battery.sh

echo "`date` switch-headphones" >> $LOG_PATH
volumeLevel="$(printf '\uf028\n') $(get-volume-level)%"

blStatus=$(bluetoothctl info $HEADPHONES_MAC_ADDR)

function show-headphones-message() {
            blStatus=$(bluetoothctl info $HEADPHONES_MAC_ADDR)
        name=$(echo $blStatus | grep -oP '(?<=Name: ).*' )
        battery_level=$(echo $blStatus | grep -oP '(?<=Battery Percentage: ).*' | awk '{print $2}' | tr -d \(\))
        message="$(get_battery_icon $battery_level) $battery_level% $(get_audio_status)"
        notify-send "$name connected" "$message" -i headphones
}

if ([[ "$blStatus" == *"Device $HEADPHONES_MAC_ADDR not available"* ]]); then
    notify-send "Headphones not available" "$(get_audio_status)" -i headphones-disconnect  
else
    isConnected=$(echo $blStatus | grep Connected | awk '{print $2}')

    if [[ "$isConnected" == "yes" ]]; then
        name=$(echo $blStatus | grep -oP '(?<=Name: ).*' )
        battery_level=$(echo $blStatus | grep -oP '(?<=Battery Percentage: ).*' | awk '{print $2}' | tr -d \(\))
        message="$(get_battery_icon $battery_level) $battery_level% $(get_audio_status)"
        echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
        notify-send "$name disconnected" "$message" -i headphones-disconnect 
    else
        echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
        sleep 2
    fi
fi
