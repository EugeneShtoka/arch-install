#!/bin/zsh

name=$1
dir=$2

cmd="wezterm cli set-tab-title 'Neovim: $name' && cd '$dir' && nvim . && clr"
if [[ -n $WEZTERM_PANE ]]; then
  /usr/bin/wezterm cli spawn -- /usr/bin/zsh -ic $cmd
else
  /usr/bin/wezterm start -- /usr/bin/zsh -ic $cmd
fi
