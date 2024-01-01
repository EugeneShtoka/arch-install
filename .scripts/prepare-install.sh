#!/bin/bash

mv ~/arch-install/.config/hypr/hyprland.conf ~/.config/hypr/
mv ~/arch-install/.config/rclone ~/.config/
sudo mv ~/arch-install/.config/systemd/user/start-up-routine.service ~/.config/systemd/user/
rm -rf ~/arch-install/.config
wget --no-check-certificate http://install.ohmyz.sh -O - | sh
rm .zshrc
rm .zshrc.pre-oh-my-zsh
mv ~/ar$SCRIPTS_PATH/install-rofi.shch-install/.* ~/

yes | sudo pacman -S curl zsh inotify-tools thunar rofi adapta-gtk-theme arc-gtk-theme kwallet-pam adobe-source-code-pro-fonts bluez bluez-utils brightnessctl
yes | sudo pacman -R dolphin kio-extras kio5 kwallet5
localectl set-locale LC_TIME=en_GB.UTF-8

#Select Cobalt-Neon theme
kitty +kitten themes

chsh -s $(which zsh)
source ~/.env
nohup zsh $SCRIPTS_PATH/install.sh
