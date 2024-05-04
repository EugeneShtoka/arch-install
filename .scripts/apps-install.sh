#!/bin/zsh

yes | sudo pacman -Syi inotify-tools thunar rofi bluz bluez-utils brightnessctl docker-compose gnome-keyring bitwarden-cli jq python-packaging gvfs p7zip dunst upower xclip cups ghostscript go adobe-source-code-pro-fonts ttf-nerd-fonts-symbols ttf-font-awesome terraform aws-cli kubectl expac maim vlc bc eza upx vivaldi vivaldi-ffmpeg-codecs npm rclone qemu-full obsidian glab github-cli qbittorrent

$SCRIPTS_PATH/yay-install.sh

$SCRIPTS_PATH/auto-yay.sh slack-desktop
$SCRIPTS_PATH/auto-yay.sh zoom
$SCRIPTS_PATH/auto-yay.sh mailspring
$SCRIPTS_PATH/auto-yay.sh beeper
$SCRIPTS_PATH/auto-yay.sh visual-studio-code-bin
$SCRIPTS_PATH/auto-yay.sh docker-desktop
$SCRIPTS_PATH/auto-yay.sh cloud-sql-proxy-bin
$SCRIPTS_PATH/auto-yay.sh autokey-gtk
$SCRIPTS_PATH/auto-yay.sh postman-bin
$SCRIPTS_PATH/auto-yay.sh adw-gtk3
$SCRIPTS_PATH/auto-yay.sh koodo-reader-bin
$SCRIPTS_PATH/auto-yay.sh google-cloud-cli
$SCRIPTS_PATH/auto-yay.sh google-cloud-cli-gke-gcloud-auth-plugin

yes | sudo pacman -Syu
yes | sudo pacman -Rns $(pacman -Qtdq)