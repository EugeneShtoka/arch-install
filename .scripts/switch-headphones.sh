source ~/.env
echo "`date` switch-headphones" >> $HOME/scripts.log

status=$(bluetoothctl info $HEADPHONES_MAC_ADDR | grep Connected | awk '{print $2}')

if [[ "$status" == "yes" ]]; then
    echo $(bluetoothctl disconnect $HEADPHONES_MAC_ADDR)
else
    echo $(bluetoothctl connect $HEADPHONES_MAC_ADDR)
fi
