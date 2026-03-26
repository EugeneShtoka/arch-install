#!/bin/zsh

name=$1
dir=$2

cmd="wezterm cli set-tab-title 'Neovim: $name' 2>/dev/null; cd '$dir' && nvim ."

if wezterm cli list &>/dev/null; then
    pane_id=$(/usr/bin/wezterm cli spawn -- /usr/bin/zsh -ilc $cmd)
    wezterm cli activate-pane --pane-id $pane_id
else
    /usr/bin/wezterm start -- /usr/bin/zsh -ilc "$cmd" &
fi

i3-msg '[class="org.wezfurlong.wezterm"] focus'
