#!/bin/zsh

echo "`date` library-auto-sync" >> $LOG_PATH
inotifywait -q -r -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $LIBRARY_PATH | while read DIR EVENT FILE
do
    echo "`date` library-auto-sync $EVENT on $DIR$FILE" >> $LOG_PATH
    $SCRIPTS_PATH/library-sync-to-gdrive.sh
done