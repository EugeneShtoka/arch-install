#!/bin/zsh

name=$1
dir=$2

cmd="wezterm cli set-tab-title 'Neovim: $name' 2>/dev/null; cd '$dir' && nvim . && clr"
wezterm cli spawn -- /usr/bin/zsh -ic $cmd
