#!/bin/zsh

echo "`date` switch-headphones" >> $LOG_PATH

blStatus=$(bluetoothctl info $HEADPHONES_MAC_ADDR)
if ([[ "$blStatus" == *"Device $HEADPHONES_MAC_ADDR not available"* ]]); then
    echo "not available"
fi

isConnected=$(echo $blStatus | grep Connected | awk '{print $2}')
if [[ "$bl-status" == "yes" ]]; then
    echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
else
    echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
fi
