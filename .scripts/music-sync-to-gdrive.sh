#!/bin/zsh

rclone sync $MUSIC_PATH $GDRIVE_NAME:$MUSIC_GDRIVE_PATH --exclude '{.git,.trash}/**' --exclude '.gitignore'
