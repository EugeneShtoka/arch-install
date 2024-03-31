#!/bin/zsh

source $SCRIPTS_PATH/bw-pass.sh
bw_pass | xclip -selection clipboard
