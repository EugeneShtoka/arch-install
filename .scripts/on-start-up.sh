#!/bin/zsh

source ~/.env

echo "$(date) on-start-up $HOME $LOG_PATH $SCRIPTS_PATH" >>"$LOG_PATH"
mkdir -p ~/.tmp
ssh-agent -a ~/.tmp/ssh-agent.sock > /dev/null
$SCRIPTS_PATH/ssh-add-keys.sh

$SCRIPTS_PATH/custom-scripts-auto-sync.sh &

wait
