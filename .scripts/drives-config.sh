#!/bin/zsh

$SCRIPTS_PATH/drives-mount.sh

dirs=("dev" "Documents" "Galina's Documents" "Downloads" "Library" "Music" "Notes" "Pictures" "Screenshots" "Torrents")
for dir in "${dirs[@]}"; do
    rm -rf ~/$dir
    ln -s /mnt/Vault/$dir ~/$dir
done

mkdir $HOME/dev
# Add dev entry to fstab
{
    echo ""
    echo "# dev"
    echo "/mnt/Vault/dev					/home/eugene/dev	none		bind	0  0"
} | sudo tee -a /etc/fstab > /dev/null

mkdir $HOME/Notes
{
    echo ""
    echo "# Notes"
    echo "/mnt/Vault/Notes					/home/eugene/Notes	none		bind	0  0"
} | sudo tee -a /etc/fstab > /dev/null