#!/bin/zsh

git clone git@github.com:jagannatharjun/qbt-theme.git
mkdir .config/qBittorrent/themes/
mv qbt-theme/*.qbtheme .config/qBittorrent/ .config/qBittorrent/themes/
rm -rf qbt-theme