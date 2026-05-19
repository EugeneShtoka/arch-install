#!/bin/zsh

name=$1
dir=$2
$SCRIPTS_PATH/wezterm-focus-or-launch.sh "Neovim: $name" /usr/bin/zsh -ilc "cd '$dir' && nvim ."
