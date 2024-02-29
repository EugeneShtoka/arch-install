#!/bin/zsh

source $SCRIPTS_PATH/volume.sh

if [[ "$1" == "Volume"]]
  if [[ "$2" == "decreased" ]]
    icon=volume-low
  elif [[ "$2" == "muted" ]]
    icon=volume-mute
  else
    icon=volume-high
  fi
elif [[ "$1" == "Microphone" ]]
  if [[ "$2" == "muted" ]]
    icon=microphone-mute
  else
    icon=microphone
  fi
fi

notify-send "$1 $2" "$(get_audio_status)" --icon $icon