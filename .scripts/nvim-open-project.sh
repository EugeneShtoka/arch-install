#!/bin/zsh

name=$1
dir=$2

cmd="wezterm cli set-tab-title 'Neovim: $name' 2>/dev/null; cd '$dir' && nvim ."
pane_id=$(/usr/bin/wezterm cli spawn -- /usr/bin/zsh -ic $cmd)
/usr/bin/wezterm cli activate-pane --pane-id $pane_id
i3-msg '[class="org.wezfurlong.wezterm"] focus'
