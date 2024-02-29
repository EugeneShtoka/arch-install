#!/bin/zsh

source $SCRIPTS_PATH/volume.sh

target=$1
action=$2

if [[ "$target" == "Volume"]]
  if [[ "$action" == "decreased" ]]
    icon=volume-low
  elif [[ "$action" == "muted" ]]
    icon=volume-mute
  else
    icon=volume-high
  fi
elif [[ "$target" == "Microphone" ]]
  if [[ "$action" == "muted" ]]
    icon=microphone-mute
  else
    icon=microphone
  fi
fi

notify-send "$1 $2" "$(get_audio_status)" --icon $icon