#!/bin/zsh
# Focus a wezterm tab by title, or open a new one running CMD
# Usage: wezterm-focus-or-launch.sh "Tab Title" cmd [args...]

TAB_TITLE="$1"
shift

wez_json=$(wezterm cli list --format json 2>/dev/null) || wez_json='[]'

tab_entry=$(echo "$wez_json" | jq -rc --arg t "$TAB_TITLE" '.[] | select(.tab_title == $t)' | head -1)

if [[ -n "$tab_entry" ]]; then
  tab_id=$(echo "$tab_entry" | jq -r '.tab_id')
  win_id=$(echo "$tab_entry" | jq -r '.window_id')

  i3_tree=$(i3-msg -t get_tree)

  wez_i3_map=$(echo "$i3_tree" | jq -r '
    [.. | objects | select(.window != null)
      | select(.window_properties.class == "org.wezfurlong.wezterm")] |
    .[] | "\(.name)\t\(.id)"
  ' | sed 's/\[[0-9]*\/[0-9]*\] //')

  pane_to_winid=$(echo "$wez_json" | jq -r '.[] | "\(.title)\t\(.window_id)"' | sort -u)

  typeset -A winid_to_conid
  while IFS=$'\t' read -r pane_title con_id; do
    winid=$(echo "$pane_to_winid" | awk -F'\t' -v t="$pane_title" '$1 == t {print $2; exit}')
    [[ -n "$winid" ]] && winid_to_conid[$winid]="$con_id"
  done <<< "$wez_i3_map"

  con_id="${winid_to_conid[$win_id]}"
  [[ -n "$con_id" ]] && i3-msg "[con_id=$con_id] focus"
  wezterm cli activate-tab --tab-id "$tab_id" 2>/dev/null
else
  if pgrep -x wezterm-gui &>/dev/null; then
    pane_id=$(wezterm cli spawn -- "$@" 2>/dev/null)
    [[ -n "$pane_id" ]] && wezterm cli set-tab-title --pane-id "$pane_id" "$TAB_TITLE" 2>/dev/null
    [[ -n "$pane_id" ]] && wezterm cli activate-pane --pane-id "$pane_id" 2>/dev/null
  else
    setsid wezterm start -- "$@" &
    until pane_id=$(wezterm cli list --format json 2>/dev/null | jq -r '.[0].pane_id // empty') && [[ -n "$pane_id" ]]; do sleep 0.1; done
    until wezterm cli set-tab-title --pane-id "$pane_id" "$TAB_TITLE" 2>/dev/null; do sleep 0.1; done
    wezterm cli activate-pane --pane-id "$pane_id" 2>/dev/null
  fi
  # Re-assert title after app starts (apps may push OSC title sequences on init)
  sleep 2 && wezterm cli set-tab-title --pane-id "$pane_id" "$TAB_TITLE" 2>/dev/null &
  i3-msg '[class="org.wezfurlong.wezterm"] focus' &>/dev/null
fi
