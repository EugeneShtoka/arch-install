#!/bin/zsh

name=$1
dir=$2

cmd="wezterm cli set-tab-title 'Neovim: $name' && cd '$dir' && nvim . && clr"
log=~/.scripts.log
echo "$(date) spawn: name=$name dir=$dir" >> $log
/usr/bin/wezterm cli spawn -- /usr/bin/zsh -ic $cmd >> $log 2>&1
spawn_exit=$?
echo "$(date) spawn exit=$spawn_exit" >> $log
if [[ $spawn_exit -ne 0 ]]; then
  /usr/bin/wezterm start -- /usr/bin/zsh -ic $cmd >> $log 2>&1
  echo "$(date) start exit=$?" >> $log
fi
