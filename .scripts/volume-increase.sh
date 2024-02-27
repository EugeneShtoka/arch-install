#!/bin/zsh

echo "`date` switch-headphones" >> $LOG_PATH
volumeLevel="60%"

blStatus=$(bluetoothctl info $HEADPHONES_MAC_ADDR)
if ([[ "$blStatus" == *"Device $HEADPHONES_MAC_ADDR not available"* ]]); then
    notify-send "Headphones not available" "Volume: $volumeLevel" -i volume-high  
else
    isConnected=$(echo $blStatus | grep Connected | awk '{print $2}')
    if [[ "$bl-status" == "yes" ]]; then
        echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
        notify-send "Headphones disconnected" "Volume: $volumeLevel" -i headphones-disconnect 
    else
        echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
        notify-send "Headphones connected" "Volume: $volumeLevel" -i headphones    
    fi
fi
