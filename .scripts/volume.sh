#!/bin/zsh

source $SCRIPTS_PATH/bluetooth.sh

# Volume information (assumes PulseAudio)
get-audio-level() {
    printf $(pactl get-sink-volume $(pactl get-default-sink) | grep -Pom 1 '[0-9]*%' | head -1 | tr -d %)
}

get-microphone-level() {
    printf $(pactl get-source-volume $(pactl get-default-source) | grep -Pom 1 '[0-9]*%' | head -1 | tr -d %)
}

function is_audio_muted() {
  echo $(pactl get-sink-mute $(pactl get-default-sink) | awk '{print $2}')
}

function is_microphone_muted() {
  echo $(pactl get-source-mute $(pactl get-default-source) | awk '{print $2}')
}

function get_audio_icon() {
  if [[ $(is_bluetooth_connected) == "yes" ]]; then
    echo "f025"
  else
    if [[ $(is_audio_muted) == "no" ]]; then echo "f028"; else echo "f026"; fi
  fi
}

function get_microphone_icon() {
  if [[ $(is_microphone_muted) == "no" ]]; then echo "f028"; else echo "f026"; fi
}

function get_audio_status() {
    printf "\u$(get_audio_icon) $(get-audio-level)%% \u$(get_microphone_icon) $(get-microphone-level)%%"
}