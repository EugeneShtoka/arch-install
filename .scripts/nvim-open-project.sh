#!/bin/zsh

name=$1
dir=$2
TAB_TITLE="Neovim: $name"
cmd="cd '$dir' && nvim ."

# Focus existing tab if already open
tab_entry=$(wezterm cli list --format json 2>/dev/null | jq -rc --arg t "$TAB_TITLE" '.[] | select(.tab_title == $t)' | head -1)
if [[ -n "$tab_entry" ]]; then
  tab_id=$(echo "$tab_entry" | jq -r '.tab_id')
  wezterm cli activate-tab --tab-id "$tab_id" 2>/dev/null
  i3-msg '[class="org.wezfurlong.wezterm"] focus'
  exit 0
fi

if pgrep -x wezterm-gui &>/dev/null; then
    pane_id=$(/usr/bin/wezterm cli spawn -- /usr/bin/zsh -ilc "$cmd")
    wezterm cli set-tab-title --pane-id $pane_id "$TAB_TITLE"
    wezterm cli activate-pane --pane-id $pane_id
else
    setsid /usr/bin/wezterm start -- /usr/bin/zsh -ilc "$cmd" &
    until pane_id=$(wezterm cli list --format json 2>/dev/null | jq -r '.[0].pane_id // empty') && [[ -n $pane_id ]]; do sleep 0.1; done
    until wezterm cli set-tab-title --pane-id $pane_id "$TAB_TITLE" 2>/dev/null; do sleep 0.1; done
    wezterm cli activate-pane --pane-id $pane_id
    sleep 2 && wezterm cli set-tab-title --pane-id $pane_id "$TAB_TITLE" 2>/dev/null &
fi

i3-msg '[class="org.wezfurlong.wezterm"] focus'
