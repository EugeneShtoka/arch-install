#!/bin/zsh

nohup $SCRIPTS_PATH/obsidian-push.sh &>/dev/null
nohup $SCRIPTS_PATH/obsidian-sync-to-gdrive.sh &>/dev/null

