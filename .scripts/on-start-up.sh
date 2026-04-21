#!/bin/zsh

source ~/.env

echo "$(date) on-start-up $HOME $LOG_PATH $SCRIPTS_PATH" >>"$LOG_PATH"
source $SCRIPTS_PATH/ssh-init.sh

$SCRIPTS_PATH/custom-scripts-auto-sync.sh &

wait
