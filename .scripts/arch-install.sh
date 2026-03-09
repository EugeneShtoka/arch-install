#!/bin/zsh

source ~/.env

yes | sudo pacman -Sy wezterm curl zsh zsh-autosuggestions zsh-syntax-highlighting zoxide
yes | sudo pacman -R xterm pipewire pipewire-pulse alacritty

localectl set-locale LC_TIME=en_GB.UTF-8

sudo mkdir -p $ZSH_PLUGINS_PATH/sudo $ZSH_PLUGINS_PATH/dirhistory
sudo curl -o $ZSH_PLUGINS_PATH/sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
sudo curl -o $ZSH_PLUGINS_PATH/dirhistory/dirhistory.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/dirhistory/dirhistory.plugin.zsh


chsh -s $(which zsh)
zsh $SCRIPTS_PATH/apps-install.sh
zsh $SCRIPTS_PATH/arch-config.sh
