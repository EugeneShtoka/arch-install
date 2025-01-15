#!/bin/zsh

$SCRIPTS_PATH/drives-mount.sh
VAULT_PATH=/mnt/Vault

mounts=("dev" "Documents" "Galina's Documents" "Library" "Music" "Notes" "Pictures" "Photo" "Screenshots")
for mount in "${mounts[@]}"; do

    escaped_vault_path=$(echo "$VAULT_PATH/$mount" | sed 's/ /\\040/g') 
    escaped_home_path=$(echo "$HOME/$mount" | sed 's/ /\\040/g') 
    echo "Mounting $escaped_vault_path to $escaped_home_path"
    # Add dev entry to fstab
    {
        echo ""
        echo "# $mount"
        echo "$escaped_vault_path                    $escaped_home_path    none        bind    0  0"
    } | sudo tee -a /etc/fstab2 >/dev/null
done

rm -rf ~/Games
ln -s /mnt/Games ~/Games
