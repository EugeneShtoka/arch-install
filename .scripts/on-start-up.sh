#!/bin/bash

echo "`date` on-start-up ${SCRIPTS_PATH} ${PWD} ${}" >> ~/.scripts.log
eval "$(ssh-agent)"
$SCRIPTS_PATH/ssh-add-keys.sh
$SCRIPTS_PATH/custom-scripts-pull.sh
sleep 10
$SCRIPTS_PATH/auto-sync-scripts.sh
