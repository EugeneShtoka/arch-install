#!/bin/bash

yes | sudo pacman -S git curl zsh inotify-tools thunar rofi adobe-source-code-pro-fonts bluez bluez-utils brightnessctl jre17-openjdk dbeaver postgresql docker-compose gnome-keyring bitwarden-cli jq python-packaging gvfs p7zip kitty notification-daemon upower xclip
yes | sudo pacman -R xterm
yes | sudo pacman -Rns $(pacman -Qtdq)

localectl set-locale LC_TIME=en_GB.UTF-8

#Select Cobalt-Neon theme
kitty +kitten themes

wget --no-check-certificate http://install.ohmyz.sh -O - | sh
rm .zshrc
mv .zshrc.pre-oh-my-zsh .zshrc

ZSH_AUTOSUGGESTION_PATH=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
rm -rf $ZSH_AUTOSUGGESTION_PATH
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_AUTOSUGGESTION_PATH

ZSH_SYNTAX_HIGHLIGHTING_PATH=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
rm -rf $ZSH_SYNTAX_HIGHLIGHTING_PATH
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_SYNTAX_HIGHLIGHTING_PATH

chsh -s $(which zsh)
source ~/.env
zsh $SCRIPTS_PATH/apps-install.sh
zsh $SCRIPTS_PATH/config-install.sh

