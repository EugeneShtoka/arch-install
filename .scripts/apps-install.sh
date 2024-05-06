#!/bin/zsh

$SCRIPTS_PATH/yay-install.sh
$SCRIPTS_PATH/apps-install-yay.sh

yay
yes | sudo pacman -Syu
yes | sudo pacman -Rns $(pacman -Qtdq)