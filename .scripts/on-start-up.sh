#!/bin/bash

echo "`date` on-start-up ${SCRIPTS_PATH}" >> $SCRIPTS_PATH
eval "$(ssh-agent)"
$SCRIPTS_PATH/ssh-add-keys.sh
$SCRIPTS_PATH/custom-scripts-pull.sh
sleep 10
$SCRIPTS_PATH/custom-scripts-auto-sync.sh
$SCRIPTS_PATH/library-auto-sync.sh
