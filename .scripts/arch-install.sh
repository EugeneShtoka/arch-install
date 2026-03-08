#!/bin/zsh

source ~/.env

yes | sudo pacman -Sy alacritty curl zsh zsh-autosuggestions zsh-syntax-highlighting zoxide
yes | sudo pacman -R xterm pipewire pipewire-pulse

localectl set-locale LC_TIME=en_GB.UTF-8

mkdir -p ~/.zsh/plugins/sudo ~/.zsh/plugins/dirhistory
curl -o ~/.zsh/plugins/sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
curl -o ~/.zsh/plugins/dirhistory/dirhistory.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/dirhistory/dirhistory.plugin.zsh

git clone https://github.com/olivierverdier/zsh-git-prompt.git $ZSH_GIT_PROMPT_PLUGIN

chsh -s $(which zsh)
zsh $SCRIPTS_PATH/apps-install.sh
zsh $SCRIPTS_PATH/arch-config.sh
