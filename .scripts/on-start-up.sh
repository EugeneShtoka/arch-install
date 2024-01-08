#!/bin/bash

source $HOME/.env
#echo "`date` on-start-up" >> $HOME/.scripts.log
eval "$(ssh-agent)"
$SCRIPTS_PATH/ssh-add-keys.sh
$SCRIPTS_PATH/custom-scripts-pull.sh
sleep 10
$SCRIPTS_PATH/auto-sync-scripts.sh
