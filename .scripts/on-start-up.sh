#!/bin/zsh

source ~/.env

echo "$(date) on-start-up $HOME $LOG_PATH $SCRIPTS_PATH" >>"$LOG_PATH"
"$SCRIPTS_PATH"/ip-update.sh
eval "$(ssh-agent)"
"$SCRIPTS_PATH"/ssh-add-keys.sh

# sleep 10
"$SCRIPTS_PATH"/custom-scripts-auto-sync.sh &
"$SCRIPTS_PATH"/gdrive-auto-sync.sh "$LIBRARY_PATH" "$GDRIVE_NAME":"$LIBRARY_GDRIVE_PATH" &
"$SCRIPTS_PATH"/gdrive-auto-sync.sh "$MUSIC_PATH" "$GDRIVE_NAME":"$MUSIC_GDRIVE_PATH" &
"$SCRIPTS_PATH"/gdrive-auto-sync.sh "$DOCUMENTS_PATH" "$GDRIVE_NAME":"$DOCUMENTS_GDRIVE_PATH" &
"$SCRIPTS_PATH"/gdrive-auto-sync.sh "$DOCUMENTS_GALINA_PATH" "$GDRIVE_GALINA_NAME":"$DOCUMENTS_GALINA_GDRIVE_PATH" &

wait
