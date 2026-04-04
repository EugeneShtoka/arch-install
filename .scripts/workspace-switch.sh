#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-narrow"

i3_tree=$(i3-msg -t get_tree)

_wez_cache="$HOME/.cache/wezterm-tabs.json"
if [[ -f "$_wez_cache" && $(( $(date +%s) - $(stat -c %Y "$_wez_cache") )) -lt 90 ]]; then
  wez_json=$(< "$_wez_cache")
else
  wez_json=$(wezterm cli list --format json 2>/dev/null) || wez_json='[]'
fi

entries=()
actions=()

# Wezterm tabs: one entry per tab
if [[ "$wez_json" != "[]" ]]; then
  # pane_title -> i3 con_id (via i3 tree wezterm windows)
  wez_i3_map=$(echo "$i3_tree" | jq -r '
    [.. | objects | select(.window != null)
      | select(.window_properties.class == "org.wezfurlong.wezterm")] |
    .[] | "\(.name)\t\(.id)"
  ' | sed 's/\[[0-9]*\/[0-9]*\] //')

  # pane_title -> wezterm window_id
  pane_to_winid=$(echo "$wez_json" | jq -r '.[] | "\(.title)\t\(.window_id)"' | sort -u)

  # wezterm window_id -> i3 con_id
  typeset -A winid_to_conid
  while IFS=$'\t' read -r pane_title con_id; do
    winid=$(echo "$pane_to_winid" | awk -F'\t' -v t="$pane_title" '$1 == t {print $2; exit}')
    [[ -n "$winid" ]] && winid_to_conid[$winid]="$con_id"
  done <<< "$wez_i3_map"

  while IFS=$'\t' read -r win_id tab_id tab_title; do
    con_id="${winid_to_conid[$win_id]}"
    [[ -z "$con_id" ]] && continue
    entries+=("$tab_title")
    actions+=("wez"$'\t'"${con_id}"$'\t'"${tab_id}")
  done < <(echo "$wez_json" | jq -r '
    group_by(.tab_id) | map(.[0]) | sort_by(.tab_id) |
    .[] | "\(.window_id)\t\(.tab_id)\t\(if .tab_title != "" then .tab_title else .title end)"
  ')
fi

# Non-wezterm i3 windows
while IFS=$'\t' read -r con_id app_name; do
  entries+=("$app_name")
  actions+=("i3"$'\t'"${con_id}")
done < <(echo "$i3_tree" | jq -r '
  def rename: {
    "Vivaldi-stable": "Web browser",
    "NeoMutt": "Email",
    "Yazi": "File browser",
    "ticker": "Stocks"
  } as $names | $names[.] // .;
  [.. | objects | select(.window != null)
    | select(.window_properties.class != "org.wezfurlong.wezterm")] |
  .[] | "\(.id)\t\(.window_properties.class | rename)"
')

[[ ${#entries[@]} -eq 0 ]] && exit

selected_idx=$(printf "%s\n" "${entries[@]}" | \
  $SCRIPTS_PATH/rofi-run.sh -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "window" -matching fuzzy -i -format i)

[[ -z "$selected_idx" || "$selected_idx" == "-1" ]] && exit

action="${actions[$((selected_idx + 1))]}"
action_type="${action%%$'\t'*}"
rest="${action#*$'\t'}"

if [[ "$action_type" == "wez" ]]; then
  con_id="${rest%%$'\t'*}"
  tab_id="${rest#*$'\t'}"
  [[ -n "$con_id" ]] && i3-msg "[con_id=${con_id}] focus"
  wezterm cli activate-tab --tab-id "$tab_id" 2>/dev/null
else
  i3-msg "[con_id=${rest}] focus"
fi
