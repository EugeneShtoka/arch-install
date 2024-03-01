#!/bin/zsh

source $SCRIPTS_PATH/volume.sh

target=$1
action=$2

if ([[ "$target" == "Volume" ]]); then
  if ([[ "$action" == "decreased" ]]); then
    icon=volume-low
  elif ([[ "$action" == "increased" ]]); then
    icon=volume-high
  elif ([[ $(is_audio_muted) == "yes" ]]); then
    icon=volume-high
  else
    icon=volume-mute
  fi
elif ([[ "$target" == "Microphone" ]]); then
  if ([[ "$(is_microphone_muted)" == "yes" ]]); then
    icon=microphone-mute
  else
    icon=microphone
  fi
fi

notify-send "$1 $2" "$(get_audio_status)" --icon $icon