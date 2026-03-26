#!/bin/zsh

name=$1
dir=$2

cmd="wezterm cli set-tab-title 'Neovim: $name' && cd '$dir' && nvim . && clr"
log=~/.scripts.log
echo "$(date) WEZTERM_PANE='$WEZTERM_PANE' cmd='$cmd'" >> $log
if [[ -n $WEZTERM_PANE ]]; then
  echo "$(date) using spawn" >> $log
  /usr/bin/wezterm cli spawn -- /usr/bin/zsh -ic $cmd >> $log 2>&1
else
  echo "$(date) using start" >> $log
  /usr/bin/wezterm start -- /usr/bin/zsh -ic $cmd >> $log 2>&1
fi
echo "$(date) exit=$?" >> $log
