#!/bin/zsh

source $SCRIPTS_PATH/get-volume-level.sh
source $SCRIPTS_PATH/get-battery-icon.sh

print_glyph() {
  printf "\u$1\n"
}

get_wifi_signal_strength() {
  current_signal=$(iwctl station wlan0 show | grep -i 'AverageRSSI' | awk '{print $2}')
  min_signal=-90
  max_signal=-30

  echo $(( (current_signal - min_signal) * 100 / (max_signal - min_signal) ))
}

# Battery information
battery_level=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d %)

# Bluetooth headphones status (requires some setup - see notes below)
bt_status=$(bluetoothctl info | grep 'Connected' | awk '{print $2}')

# CPU, RAM, IO usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
ram_usage=$(free -m | awk 'NR==2{printf "%.0f%%", $3*100/$2 }')
io_stats=$(iostat -d -x 1 2 | awk 'NR==4{printf "r/s: %.1f kB/s w/s: %.1f kB/s", $2, $3}') 

# Construct the message for notify-send
message="<span font='40px'>$(date +%H:%M)</span>
<span font='25px'>$(print_glyph 'f028') $(get-volume-level)%
$(print_glyph 'f025') Bluetooth: $bt_status
$(print_glyph 'f1eb') $(get_wifi_signal_strength)% $(iwgetid -r)
$(get_battery_icon $battery_level) $battery_level% $(print_glyph 'f013') $cpu_usage $(print_glyph 'f2db') $ram_usage</span>"

# Send the notification
notify-send "$(date +%d.%m.%Y)" "$message"
