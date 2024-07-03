#!/bin/zsh

source ~/.env

echo "`date` on-start-up $HOME $LOG_PATH $SCRIPTS_PATH" >> $LOG_PATH
eval "$(ssh-agent)"
$SCRIPTS_PATH/ssh-add-keys.sh
sleep 10
$SCRIPTS_PATH/library-sync-from-gdrive.sh
$SCRIPTS_PATH/custom-scripts-pull.sh
sleep 10
$SCRIPTS_PATH/custom-scripts-auto-sync.sh
$SCRIPTS_PATH/library-auto-sync.sh
