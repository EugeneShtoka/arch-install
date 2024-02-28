#!/bin/zsh

# showStatus() {
#     battery=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}')
#     tput sc;
#     tput cup 0 $(($(tput cols)-10));
#     echo -e "\033[1;33m$battery `date +%H:%M`\033[0m";
#     tput rc;
# }

# echo
# showStatus;
# while sleep 60; do 
#     showStatus;
# done &

formattedDate=$(date +%d.%m.%Y)
formattedTime=$(date +%H:%M)
battery=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}')
#notify-send "$formattedDate" "<span font='40px'>$formattedTime\n</span><span font='30px'>Battery: $battery</span>"


# Get basic information
current_date=$(date +%d.%m.%Y)
current_time=$(date +%H:%M)

battery_level=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d %)
get_battery_icon() {
  if (( battery_level >= 80 )); then
    printf "\uf240\n"
  elif (( battery_level >= 60 )); then
    printf "\uf241\n"
  elif (( battery_level >= 40 )); then
    printf "\uf242\n"
  elif (( battery_level > 20 )); then 
    printf "\uf243\n"
  else
    printf "\uf244\n"
  fi
}

wifi_ssid=$(iwgetid -r)
wifi_status=$(nmcli radio wifi)

# Volume information (assumes PulseAudio)
default_sink=$(pactl info | grep 'Default Sink' | awk '{print $3}')
volume=$(pactl list sinks | grep '^[[:space:]]Volume:' | \
    head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')

# Bluetooth headphones status (requires some setup - see notes below)
bt_status=$(bluetoothctl info | grep 'Connected' | awk '{print $2}')

# CPU, RAM, IO usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
ram_usage=$(free -m | awk 'NR==2{printf "%.0f%%", $3*100/$2 }')
io_stats=$(iostat -d -x 1 2 | awk 'NR==4{printf "r/s: %.1f kB/s w/s: %.1f kB/s", $2, $3}') 



battery_icon=

# Construct the message for notify-send
message="<span font='40px'>$current_time</span>
<span font='30px'>$(get_battery_icon): $battery_level%
WiFi: $wifi_ssid (Status: $wifi_status)
Volume: $volume%
Bluetooth: $bt_status
CPU: $cpu_usage
RAM: $ram_usage
I/O Stats: $io_stats
</span>"

# Send the notification
notify-send "$current_date" "$message"
