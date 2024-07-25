#!/bin/zsh

source $SCRIPTS_PATH/volume.sh
source $SCRIPTS_PATH/battery.sh
source $SCRIPTS_PATH/meetings.sh

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

# CPU, RAM
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.0f%%", 100 - $1"%"}')
ram_usage=$(free -m | awk 'NR==2{printf "%.0f%%", $3*100/$2 }')

hardware_info="$(print_glyph 'f013') $cpu_usage $(print_glyph 'f2db') $ram_usage"
if ([[ $(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -oP '(?<=percentage: ).*' | grep -o 'should be ignored') != "should be ignored" ]]); then
  hardware_info="$(get_battery_icon $battery_level) $battery_level% $cpu_and_ram $hardware_info"
fi


# Construct the message for notify-send
message="<span font='20px'>$(date +%d.%m.%Y)
$(date +%A)
$(get_audio_status)
$(print_glyph 'f1eb') $(get_wifi_signal_strength)% $(iwgetid -r)
$hardware_info</span>"

# Send the notification
echo $(notify-send "$(date +%H:%M)" "$message" --icon=" " --category="test")
CURRENT_ID=$?

echo "$CURRENT_ID"
