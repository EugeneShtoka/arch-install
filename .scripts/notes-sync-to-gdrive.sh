#!/bin/zsh

rclone sync $NOTES_PATH $GDRIVE_NAME:$NOTES_GDRIVE_PATH --exclude '{.git,.trash}/**' --exclude '.gitignore'
