#!/bin/zsh

sudo mkdir /mnt/Vault
sudo mkdir /mnt/Games
sudo mkdir /mnt/Archive

fstab=/etc/fstab
echo "# /dev/sda1" | sudo tee -a $fstab > /dev/null
echo "UUID=3b67c615-e56f-44e7-bc0b-090337b8d7d8	/mnt/Vault      ext4        defaults,noatime,discard,errors=remount-ro 0 2" | sudo tee -a $fstab > /dev/null
echo "# /dev/sdb1" | sudo tee -a $fstab > /dev/null
echo "UUID=8022cf23-c122-4001-9d88-e25ed922627c	/mnt/Games      ext4        defaults,noatime,discard,errors=remount-ro 0 2" | sudo tee -a $fstab > /dev/null
echo "# /dev/sdc1" | sudo tee -a $fstab > /dev/null
echo "UUID=e5ac59e1-1b47-4bb3-a605-c713968af790	/mnt/Archive    ext4        defaults 0 2" | sudo tee -a $fstab > /dev/null
