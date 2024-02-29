#!/bin/zsh

source $SCRIPTS_PATH/volume.sh

notify-send "Volume $1" "$(get_audio_status)"