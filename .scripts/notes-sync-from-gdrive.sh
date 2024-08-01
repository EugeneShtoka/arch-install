#!/bin/zsh

rclone sync $GDRIVE_NAME:$NOTES_GDRIVE_PATH $NOTES_PATH --exclude '{.git,.trash,.stfolder}/**' --exclude '.gitignore' --exclude '.syncthing*'
