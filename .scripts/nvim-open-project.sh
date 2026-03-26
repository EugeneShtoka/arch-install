#!/bin/zsh

name=$1
dir=$2

cmd="cd '$dir' && nvim ."

if [[ -S $XDG_RUNTIME_DIR/wezterm/sock ]]; then
    pane_id=$(/usr/bin/wezterm cli spawn -- /usr/bin/zsh -ilc "$cmd")
    wezterm cli set-tab-title --pane-id $pane_id "Neovim: $name"
    wezterm cli activate-pane --pane-id $pane_id
else
    /usr/bin/wezterm start -- /usr/bin/zsh -ilc "$cmd" &
    until [[ -S $XDG_RUNTIME_DIR/wezterm/sock ]]; do sleep 0.1; done
    until pane_id=$(wezterm cli list --format json 2>/dev/null | jq -r '.[0].pane_id // empty') && [[ -n $pane_id ]]; do sleep 0.1; done
    wezterm cli set-tab-title --pane-id $pane_id "Neovim: $name"
    wezterm cli activate-pane --pane-id $pane_id
fi

i3-msg '[class="org.wezfurlong.wezterm"] focus'
