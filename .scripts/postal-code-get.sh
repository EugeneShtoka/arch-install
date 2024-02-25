#!/bin/zsh

source $SCRIPTS_PATH/bw-unlock.sh
bw get item 'address' | jq '.notes' | jq 'fromjson .zip' | xclip -selection c