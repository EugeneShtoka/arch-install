#!/bin/zsh

nohup $SCRIPTS_PATH/notes-push.sh &>/dev/null
"$SCRIPTS_PATH"/gdrive-auto-sync.sh "$NOTES_PATH" "$GDRIVE_NAME":"$NOTES_GDRIVE_PATH" &
