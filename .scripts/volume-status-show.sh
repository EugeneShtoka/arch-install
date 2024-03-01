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
    icon=volume-mute 
    action="muted"
  else
    icon=volume-high
    action="unmuted"
  fi
elif ([[ "$target" == "Microphone" ]]); then
  if ([[ "$(is_microphone_muted)" == "yes" ]]); then
    icon=microphone-mute
    action="muted"
  else
    icon=microphone
    action="unmuted"
  fi
fi

notify-send "$target $action" "$(get_audio_status)" --icon $icon