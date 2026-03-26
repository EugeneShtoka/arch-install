#!/bin/zsh

name=$1
dir=$2

pane_id=$(/usr/bin/wezterm cli spawn -- /usr/bin/zsh -i)
/usr/bin/wezterm cli activate-pane --pane-id $pane_id
i3-msg '[class="org.wezfurlong.wezterm"] focus'
