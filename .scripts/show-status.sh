showStatus() {
    battery=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}')
    tput sc;
    tput cup 0 $(($(tput cols)-10));
    echo -e "\033[1;33m$battery `date +%H:%M`\033[0m";
    tput rc;
}

echo
showStatus;
while sleep 60; do 
    showStatus;
done &

