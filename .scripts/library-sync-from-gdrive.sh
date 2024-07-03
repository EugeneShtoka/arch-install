#!/bin/zsh

echo "`date` library-sync-from-gdrive" >> $LOG_PATH
rclone sync $GDRIVE_NAME:$LIBRARY_GDRIVE_PATH $LIBRARY_PATH
