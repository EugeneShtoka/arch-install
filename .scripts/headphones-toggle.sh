#!/bin/zsh

echo "`date` switch-headphones" >> $LOG_PATH

notAvailable = "Device $HEADPHONES_MAC_ADDR not available"
blStatus=$(bluetoothctl info $HEADPHONES_MAC_ADDR)

if ([[ "$blStatus" == *"$notAvailable"* ]]); then
    echo "not available"
fi

if [[ "$bl-status" == "yes" ]]; then
    echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
else
    echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
fi
