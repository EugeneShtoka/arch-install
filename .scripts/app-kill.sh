#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-narrow"

i3_tree=$(i3-msg -t get_tree)
wez_json=$($SCRIPTS_PATH/wezterm-tabs-get.sh)

entries=()
actions=()

# GUI apps from i3 (excluding wezterm)
while IFS=$'\t' read -r class display_name; do
  [[ -z "$class" ]] && continue
  entries+=("$display_name")
  actions+=("gui"$'\t'"$class")
done < <(echo "$i3_tree" | jq -r '
  def rename: {
    "Vivaldi-stable": "Web browser",
    "Mailspring": "eMail",
    "Yazi": "File browser",
    "ticker": "Stocks"
  } as $names | $names[.] // .;
  [.. | objects | select(.window != null)
    | select(.window_properties.class != "org.wezfurlong.wezterm")
    | .window_properties.class] | unique | sort |
  .[] | "\(.)\t\(. | rename)"
')

# Wezterm tabs
if [[ "$wez_json" != "[]" ]]; then
  while IFS=$'\t' read -r pane_id tab_title; do
    [[ -z "$pane_id" ]] && continue
    entries+=("Terminal: $tab_title")
    actions+=("wez-tab"$'\t'"$pane_id")
  done < <(echo "$wez_json" | jq -r '
    group_by(.tab_id) | map(.[0]) | sort_by(.tab_id) |
    .[] | "\(.pane_id)\t\(if .tab_title != "" then .tab_title else .title end)"
  ')
fi

# VLC if running
if pgrep -x vlc &>/dev/null || pgrep -x cvlc &>/dev/null; then
  entries+=("Media player")
  actions+=("proc"$'\t'"vlc")
fi

[[ ${#entries[@]} -eq 0 ]] && exit

selected_idx=$(printf "%s\n" "${entries[@]}" | \
  $SCRIPTS_PATH/rofi-run.sh -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "kill" -matching fuzzy -i -format i)

[[ -z "$selected_idx" || "$selected_idx" == "-1" ]] && exit

action="${actions[$((selected_idx + 1))]}"
action_type="${action%%$'\t'*}"
target="${action#*$'\t'}"

case "$action_type" in
  gui)
    xdotool search --class "$target" 2>/dev/null | xargs -I{} xdotool windowclose {} 2>/dev/null
    sleep 0.3
    pkill -if "$target" 2>/dev/null
    ;;
  wez-tab)
    wezterm cli kill-pane --pane-id "$target" 2>/dev/null
    (sleep 1 && $SCRIPTS_PATH/wezterm-tabs-update.sh) &
    disown
    ;;
  proc)
    pkill -9 -f "$target" 2>/dev/null
    ;;
esac
