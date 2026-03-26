#!/bin/zsh

LOG=/tmp/nvim-open-project.log
exec >>"$LOG" 2>&1
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH
echo "=== $(date) args: $@ ==="
echo "DISPLAY=$DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
echo "PATH=$PATH"

name=$1
dir=$2

cmd="cd '$dir' && nvim ."

if pgrep -x wezterm-gui &>/dev/null; then
    echo "wezterm running, spawning pane"
    pane_id=$(/usr/bin/wezterm cli spawn -- /usr/bin/zsh -ilc "$cmd" 2>&1)
    echo "pane_id=$pane_id"
    wezterm cli set-tab-title --pane-id $pane_id "Neovim: $name"
    wezterm cli activate-pane --pane-id $pane_id
else
    echo "wezterm not running, starting"
    setsid /usr/bin/wezterm start -- /usr/bin/zsh -ilc "$cmd" &
    until pane_id=$(wezterm cli list --format json 2>/dev/null | jq -r '.[0].pane_id // empty') && [[ -n $pane_id ]]; do sleep 0.1; done
    echo "pane_id=$pane_id"
    wezterm cli set-tab-title --pane-id $pane_id "Neovim: $name"
    wezterm cli activate-pane --pane-id $pane_id
fi

echo "i3-msg focus"
i3-msg '[class="org.wezfurlong.wezterm"] focus'
echo "done"
