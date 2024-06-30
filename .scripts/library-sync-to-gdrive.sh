#!/bin/zsh


echo "`date` library-sync-to-gdrive" >> $LOG_PATH
rclone sync $LIBRARY_PATH $GDRIVE_NAME:$LIBRARY_GDRIVE_PATH --exclude '{.git,.trash}/**' --exclude '.gitignore'
