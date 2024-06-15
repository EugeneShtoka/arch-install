#!/bin/zsh

nohup $SCRIPTS_PATH/notes-push.sh &>/dev/null
nohup $SCRIPTS_PATH/notes-sync-to-gdrive.sh &>/dev/null

