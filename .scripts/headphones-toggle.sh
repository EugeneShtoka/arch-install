#!/bin/zsh

echo "`date` switch-headphones" >> $LOG_PATH

bl-status=$(bluetoothctl info $HEADPHONES_MAC_ADDR | grep Connected | awk '{print $2}')

if [[ "$bl-status" == "yes" ]]; then
    echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
else
    echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
fi
