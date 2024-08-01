#!/bin/zsh

source=$1
destination=$2

echo "$(date) gdrive-sync from $source to $destination" >>$LOG_PATH
rclone sync $source $destination --exclude '{.git,.trash,.stfolder}/**' --exclude '.gitignore' --exclude '.syncthing*' --exclude '.stignore'
