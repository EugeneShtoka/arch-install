#!/bin/zsh

source ~/.env

yes | sudo pacman -S alacritty curl zsh
yes | sudo pacman -R xterm
yes | sudo pacman -Rns $(pacman -Qtdq)

localectl set-locale LC_TIME=en_GB.UTF-8

wget --no-check-certificate http://install.ohmyz.sh -O - | sh
rm .zshrc
mv .zshrc.pre-oh-my-zsh .zshrc
rm -rf .oh-my-zsh/.git
rm -rf .oh-my-zsh/.github
rm -rf $ZSH_PLUGINS_PATH
rm $ZSH_CUSTOM/.gitignore

git clone https://github.com/olivierverdier/zsh-git-prompt.git $ZSH_GIT_PROMPT_PLUGIN
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_PLUGINS_PATH/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS_PATH/zsh-syntax-highlighting

chsh -s $(which zsh)
zsh $SCRIPTS_PATH/apps-install.sh
zsh $SCRIPTS_PATH/arch-config.sh

