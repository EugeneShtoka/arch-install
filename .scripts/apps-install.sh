#!/bin/zsh

yes | sudo pacman -S inotify-tools thunar rofi bluez bluez-utils brightnessctl docker-compose gnome-keyring bitwarden-cli jq python-packaging gvfs p7zip dunst upower xclip cups ghostscript go adobe-source-code-pro-fonts ttf-nerd-fonts-symbols ttf-font-awesome terraform aws-cli kubectl expac maim

$SCRIPTS_PATH/yay-install.sh

$SCRIPTS_PATH/auto-yay.sh slack-desktop
$SCRIPTS_PATH/auto-yay.sh zoom
$SCRIPTS_PATH/auto-yay.sh mailspring
$SCRIPTS_PATH/auto-yay.sh beeper
$SCRIPTS_PATH/auto-yay.sh obsidian
$SCRIPTS_PATH/auto-yay.sh glab-git
$SCRIPTS_PATH/auto-yay.sh github-cli
$SCRIPTS_PATH/auto-yay.sh qbittorrent-enhanced
$SCRIPTS_PATH/auto-yay.sh visual-studio-code-bin
$SCRIPTS_PATH/auto-yay.sh qemu-full
$SCRIPTS_PATH/auto-yay.sh docker-desktop
$SCRIPTS_PATH/auto-yay.sh npm
$SCRIPTS_PATH/auto-yay.sh rclone
$SCRIPTS_PATH/auto-yay.sh cloud-sql-proxy
$SCRIPTS_PATH/auto-yay.sh google-cloud-cli
$SCRIPTS_PATH/auto-yay.sh vivaldi-snapshot
$SCRIPTS_PATH/auto-yay.sh vivaldi-snapshot-ffmpeg-codecs
$SCRIPTS_PATH/auto-yay.sh autokey-gtk
$SCRIPTS_PATH/auto-yay.sh postman-bin
$SCRIPTS_PATH/auto-yay.sh adw-gtk3
$SCRIPTS_PATH/auto-yay.sh google-cloud-cli-gke-gcloud-auth-plugin

$SCRIPTS_PATH/eza-install.sh

yes | sudo pacman -Rns $(pacman -Qtdq)