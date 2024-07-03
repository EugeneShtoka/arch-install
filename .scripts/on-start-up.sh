#!/bin/zsh

source ~/.env

echo "`date` on-start-up $HOME $LOG_PATH $SCRIPTS_PATH" >> $LOG_PATH
eval "$(ssh-agent)"
$SCRIPTS_PATH/ssh-add-keys.sh &>>/dev/null &
sleep 10
$SCRIPTS_PATH/library-sync-from-gdrive.sh &
$SCRIPTS_PATH/custom-scripts-pull.sh &
sleep 10
$SCRIPTS_PATH/custom-scripts-auto-sync.sh

echo "@@@@@@@ TEST2 @@@@@@@@@@@@" >> $LOG_PATH
setsid $SCRIPTS_PATH/library-auto-sync.sh
