#!/bin/bash

echo "`date` on-start-up" >> $LOG_PATH
eval "$(ssh-agent)"
$SCRIPTS_PATH/ssh-add-keys.sh
$SCRIPTS_PATH/custom-scripts-pull.sh
sleep 10
$SCRIPTS_PATH/auto-sync-scripts.sh
