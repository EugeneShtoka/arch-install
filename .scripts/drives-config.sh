#!/bin/zsh

$SCRIPTS_PATH/drives-mount.sh
VAULT_PATH=/mnt/Vault

dirs=("Downloads" "Torrents")
for dir in "${dirs[@]}"; do
    rm -rf ~/$dir
    ln -s $VAULT_PATH/$dir ~/$dir
done

mounts=("dev" "Documents" "Galina's Documents" "Library" "Music" "Notes" "Pictures" "Photo" "Screenshots")
for mount in "${mounts[@]}"; do
    rm -rf $HOME/$mount
    mkdir $HOME/$mount

    escaped_vault_path=$(echo "$VAULT_PATH/$mount" | sed 's/ /\\040/g') 
    escaped_home_path=$(echo "$HOME/$mount" | sed 's/ /\\040/g') 
    
    # Add dev entry to fstab
    {
        echo ""
        echo "# $mount"
        echo "$VAULT_PATH/${mount// /\\040}                    $HOME/${mount// /\\040}    none        bind    0  0"
    } | sudo tee -a /etc/fstab2 >/dev/null
done

rm -rf ~/Games
ln -s /mnt/Games ~/Games
