#!/bin/zsh

name=$1
dir=$2

cmd="wezterm cli set-tab-title 'Neovim: $name' 2>/dev/null; cd '$dir' && nvim ."
log=~/.scripts.log
/usr/bin/wezterm cli spawn -- /usr/bin/zsh -ic $cmd >> $log 2>&1
echo "$(date) exit=$? cmd=$cmd" >> $log
