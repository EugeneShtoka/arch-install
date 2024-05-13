#!/bin/zsh

source $SCRIPTS_PATH/bluetooth.sh

# Volume information (assumes PulseAudio)
get-level() {
    printf $(pactl get-$1-volume $(pactl get-default-$1) | grep -Pom 1 '[0-9]*%' | head -1 | tr -d %)
}

function is_muted() {
  echo $(pactl get-$1-mute $(pactl get-default-$1) | awk '{print $2}')
}

function get_audio_icon() {
  if [[ $(is_bluetooth_connected) == "yes" ]]; then
    echo "\uf025"
  else
    if [[ $(is_muted sink) == "no" ]]; then
      echo "\uf028 $(get-level sink)%"
    else
      echo "<span color=\"magenta\">\uf026 $(get-level sink)%</span>"
    fi
  fi
}

function get_microphone_icon() {
  if [[ $(is_muted source) == "no" ]]; then
    echo "\uf130 $(get-level source)%"
  else
    echo "<span color=\"magenta\">\uf131 $(get-level source)%</span>"
  fi
}

function get_audio_status() {
    echo "$(get_audio_icon) $(get_microphone_icon)"
}