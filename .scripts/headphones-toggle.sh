#!/bin/zsh

echo "`date` switch-headphones" >> $LOG_PATH

if ([[ "$blStatus" == *"Device $HEADPHONES_MAC_ADDR not available"* ]]); then
    echo "not available"
fi

if [[ "$bl-status" == "yes" ]]; then
    echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
else
    echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
fi
