#!/bin/bash

source ~/.env

yes | sudo pacman -Sy alacritty curl zsh
yes | sudo pacman -R xterm

localectl set-locale LC_TIME=en_GB.UTF-8

sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm .zshrc
mv .zshrc.pre-oh-my-zsh .zshrc
rm -rf .oh-my-zsh/.git
rm -rf .oh-my-zsh/.github
rm -rf $ZSH_PLUGINS_PATH
rm $ZSH_CUSTOM/.gitignore

git clone https://github.com/olivierverdier/zsh-git-prompt.git $ZSH_GIT_PROMPT_PLUGIN
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_PLUGINS_PATH/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS_PATH/zsh-syntax-highlighting
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_PLUGINS_PATH/zsh-vi-mode

chsh -s $(which zsh)
zsh $SCRIPTS_PATH/apps-install.sh
zsh $SCRIPTS_PATH/arch-config.sh

