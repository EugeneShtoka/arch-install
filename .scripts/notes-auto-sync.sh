#!/bin/zsh

echo "$(date) notes-auto-sync" >>"$LOG_PATH"

inotifywait -q -r -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM "$source" | while read DIR EVENT FILE; do
    echo "$(date) gdrive-auto-sync $EVENT on $DIR$FILE" >>"$LOG_PATH"
    "$SCRIPTS_PATH"/gdrive-sync.sh "$source" "$destination"
done
