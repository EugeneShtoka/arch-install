#!/bin/zsh

add_drive() {
    local label="$1"
    local optional_options="$2"

    local mount_point="/mnt/$label"
    local uuid=$(lsblk -f | grep $label | awk '{print $5}')

    local options="defaults"
    if [[ -n "$optional_options" ]]; then
        options="$options$optional_options"
    fi

    # Create mount point
    sudo mkdir -p "$mount_point"

    # Add entry to fstab
    {
        echo ""
        echo "# $label"
        echo "UUID=$uuid $mount_point ext4  $options    0 2"
    } | sudo tee -a /etc/fstab >/dev/null
}

add_drive Vault ",noatime,discard,errors=remount-ro"
add_drive Games ",noatime,discard,errors=remount-ro"
