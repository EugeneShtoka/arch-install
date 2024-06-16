#!/bin/zsh

#$SCRIPTS_PATH/drives-mount.sh

dirs=("dev" "Documents" "Downloads" "Library" "Music" "Notes" "Pictures" "Screenshots" "Torrents")
for dir in "${dirs[@]}"; do
    rm ~/$dir
    mkdir ~/$dir
    sudo mount --bind /mnt/Vault/$dir ~/$dir
done
