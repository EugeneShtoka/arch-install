#!/bin/zsh

source $SCRIPTS_PATH/volume.sh

notify-send "$1 $2" "$(get_audio_status)"