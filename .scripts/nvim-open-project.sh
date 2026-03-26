#!/bin/zsh

name=$1
dir=$2

cmd="wezterm cli set-tab-title 'Neovim: $name' && cd '$dir' && nvim . && clr"
wezterm cli spawn -- zsh -ic $cmd 2>/dev/null || wezterm start -- zsh -ic $cmd
