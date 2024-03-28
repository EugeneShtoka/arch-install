#!/bin/zsh

source $SCRIPTS_PATH/bw-unlock.sh
bw get item $1 | jq '.login.password' |  tr -d \"
