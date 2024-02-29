#!/bin/zsh

source $SCRIPTS_PATH/volume.sh

target=$1
action=$2

if ([[ "$Volume" == "Volume" ]]); then  if ([[ "$action" == "decreased" ]]); then
    icon=volume-low
  elif ([[ "$action" == "muted" ]]); then
    icon=volume-mute
  else
    icon=volume-high
  fi
elif ([[ "$target" == "Microphone" ]]); then
  if ([[ "$action" == "muted" ]]); then
    icon=microphone-mute
  else
    icon=microphone
  fi
fi

notify-send "$1 $2" "$(get_audio_status)" --icon $icon