rclone sync $OBSIDIAN_PATH $OBSIDIAN_GDRIVE_PATH --exclude '{.git,.trash}/**' --exclude '.gitignore'
