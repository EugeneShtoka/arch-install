#!/bin/zsh

source ~/.env

echo "$(date) on-start-up $HOME $LOG_PATH $SCRIPTS_PATH" >>"$LOG_PATH"
$SCRIPTS_PATH/ip-update.sh
eval "$(ssh-agent)"
$SCRIPTS_PATH/ssh-add-keys.sh

$SCRIPTS_PATH/custom-scripts-auto-sync.sh &

wait
