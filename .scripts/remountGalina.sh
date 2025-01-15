mounts=("Galina's Documents")
for mount in "${mounts[@]}"; do
    rm -rf "$HOME/$mount"
    mkdir "$HOME/$mount"
    # Add dev entry to fstab
    {
        echo ""
        echo "# $mount"
        echo "$VAULT_PATH/$mount					$HOME/$mount	none		bind	0  0"
    } | sudo tee -a /etc/fstab >/dev/null
done