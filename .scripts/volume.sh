#!/bin/zsh

# Volume information (assumes PulseAudio)
get-volume-level() {
    printf $(pactl get-sink-volume $(pactl get-default-sink) | grep -Pom 1 '[0-9]*%' | head -1 | tr -d %)
}

function is_volume_muted() {
  echo $(pactl get-sink-mute $(pactl get-default-sink) | awk '{print $2}')
}

function get_audio_icon() {
  if [[ $1 == "yes" ]]; then
    echo "f025"
  else
    if [[ $(pactl get-sink-mute $(pactl get-default-sink) | awk '{print $2}') == "no" ]]; then
      echo "f028"
    else
      echo "f026"
    fi
  fi
}

function get_audio_status() {
    printf "\u$(get_audio_icon $bt_status) $(get-volume-level)%%"
}