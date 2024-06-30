#!/bin/zsh

$SCRIPTS_PATH/drives-mount.sh

dirs=("Downloads" "Torrents")
for dir in "${dirs[@]}"; do
    rm -rf ~/$dir
    ln -s /mnt/Vault/$dir ~/$dir
done

mounts=("dev" "Documents" "Galina's Documents" "Library" "Music" "Notes" "Pictures" "Screenshots")
for mount in "${mounts[@]}"; do
    rm $HOME/$mount
    mkdir $HOME/$mount
    # Add dev entry to fstab
    {
        echo ""
        echo "# $mount"
        echo "/mnt/Vault/$mount					/home/eugene/$mount	none		bind	0  0"
    } | sudo tee -a /etc/fstab > /dev/null
done