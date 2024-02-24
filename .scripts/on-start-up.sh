#!/bin/bash

echo "`date` on-start-up ${SCRIPTS_PATH}" >> $LOG_PATH
eval "$(ssh-agent)"
$SCRIPTS_PATH/ssh-add-keys.sh >/dev/null
$SCRIPTS_PATH/custom-scripts-pull.sh
$SCRIPTS_PATH/library-sync-from-gdrive.sh
$SCRIPTS_PATH/apps-config.sh >/dev/null
sleep 10
$SCRIPTS_PATH/custom-scripts-auto-sync.sh
$SCRIPTS_PATH/library-auto-sync.sh
