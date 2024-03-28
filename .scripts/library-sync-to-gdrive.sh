#!/bin/zsh

rclone sync $OBSIDIAN_PATH $GDRIVE_NAME:$OBSIDIAN_GDRIVE_PATH --exclude '{.git,.trash}/**' --exclude '.gitignore'
