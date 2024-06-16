#!/bin/zsh

$SCRIPTS_PATH/auto-yay.sh qbittorrent
mkdir -p .config/qBittorrent/themes/
wget https://github.com/dracula/qbittorrent/raw/master/dracula.qbtheme -P ~/.config/qBittorrent/themes/