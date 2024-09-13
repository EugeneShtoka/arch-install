#!/bin/zsh

source $SCRIPTS_PATH/volume.sh
source $SCRIPTS_PATH/battery.sh
source $SCRIPTS_PATH/wifi.sh

print_glyph() {
  printf "\u$1\n"
}

get_wifi_signal_strength() {
  current_signal=$(iwctl station wlan0 show | grep -i 'AverageRSSI' | awk '{print $2}')
  min_signal=-90
  max_signal=-30

  strength=$(( (current_signal - min_signal) * 100 / (max_signal - min_signal) ))
  echo $strength
  echo $(get_wifi_icon 10)
}

# CPU, RAM
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.0f%%", 100 - $1"%"}')
ram_usage=$(free -m | awk 'NR==2{printf "%.0f%%", $3*100/$2 }')

hardware_info="$(print_glyph 'f013') $cpu_usage $(print_glyph 'f2db') $ram_usage"
if [[ "$IS_LAPTOP" = "1" ]]; then
  get_battery_info
  hardware_info="$(get_battery_status $battery_level $discharging)$cpu_and_ram $hardware_info"
fi

# Construct the message for notify-send
message="<span font='20px'>$(date +%d.%m.%Y)
$(date +%A)
$(get_audio_status)
$(get_wifi_signal_strength) $(iwgetid -r)
$hardware_info</span>"

# Send the notification
notify-send "$(date +%H:%M)" "$message" --icon=" " -r 101039

