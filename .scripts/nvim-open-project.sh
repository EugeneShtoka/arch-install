#!/bin/zsh

name=$1
dir=$2

echo "$(date) PATH=$PATH" >> ~/.scripts.log

cmd="wezterm cli set-tab-title 'Neovim: $name' && cd '$dir' && nvim . && clr"
/usr/bin/wezterm cli spawn -- /usr/bin/zsh -ic $cmd 2>/dev/null || /usr/bin/wezterm start -- /usr/bin/zsh -ic $cmd
