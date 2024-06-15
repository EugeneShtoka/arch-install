#!/bin/zsh

$SCRIPTS_PATH/drives-mount.sh

dirs=("dev" "Documents" "Downloads" "Library" "Music" "Notes" "Pictures" "Screenshots" "Torrents")
for dir in "${dirs[@]}"; do
    rm -rf ~/$dir
    ln -s /mnt/Vault/$dir ~/$dir
done
