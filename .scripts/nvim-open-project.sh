#!/bin/zsh

name=$1
path=$2

cmd="wezterm cli set-tab-title 'Neovim: $name' && cd '$path' && nvim . && clr"
wezterm cli spawn -- zsh -ic $cmd 2>/dev/null || wezterm start -- zsh -ic $cmd
