#!/bin/zsh

source $SCRIPTS_PATH/bw-pass.sh
bw_pass $1 | xclip -selection clipboard
