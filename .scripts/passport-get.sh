#!/bin/zsh

source $SCRIPTS_PATH/bw-unlock.sh
bw get item 'passport-eugene' | jq '.notes' | jq 'fromjson'
bw get item 'passport-galina' | jq '.notes' | jq 'fromjson'