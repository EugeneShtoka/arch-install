#!/bin/zsh

source $SCRIPTS_PATH/volume.sh

target=$1
action=$2

if ([[ "$target" == "Volume" ]]); then
  if ([[ "$action" == "decreased" ]]); then
    icon=volume-low
  elif ([[ "$action" == "increased" ]]); then
    icon=volume-high
  elif ([[ $(is_muted sink) == "yes" ]]); then
    icon=volume-mute
    action=muted
  else
    icon=volume-high
    action=unmuted
  fi
elif ([[ "$target" == "Microphone" ]]); then
  if ([[ "$(is_muted source)" == "yes" ]]); then
    icon=microphone-mute
    action="muted"
  else
    icon=microphone
    action=unmuted
  fi
fi

dunstify "$target $action" "<span font='20px'>$(get_audio_status)</span>" --icon $ICONS_PATH/$icon.png