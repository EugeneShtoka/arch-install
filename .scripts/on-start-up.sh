#!/bin/bash

echo "`date` on-start-up ${SCRIPTS_PATH}" >> $SCRIPTS_PATH
eval "$(ssh-agent)"
$SCRIPTS_PATH/ssh-add-keys.sh
$SCRIPTS_PATH/custom-scripts-pull.sh
$SCRIPTS_PATH/library-sync-from-gdrive.sh
$SCRIPTS_PATH/launcher-config.sh
sleep 10
$SCRIPTS_PATH/custom-scripts-auto-sync.sh
$SCRIPTS_PATH/library-auto-sync.sh
