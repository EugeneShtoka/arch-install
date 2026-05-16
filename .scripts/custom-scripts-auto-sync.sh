#!/bin/zsh

source ~/.env

echo "`date` custom-scripts-auto-sync" >> $LOG_PATH
$SCRIPTS_PATH/custom-scripts-pull.sh
$SCRIPTS_PATH/custom-scripts-push.sh
