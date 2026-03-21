#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-wide"

# Get wezterm tabs (one per tab, using the active pane's title)
wez_tabs=()
if wez_json=$(wezterm cli list --format json 2>/dev/null); then
  while IFS=$'\t' read -r tab_id title; do
    wez_tabs+=("${tab_id}"$'\t'"${title}")
  done < <(echo "$wez_json" | jq -r 'map(select(.is_active)) | .[] | "\(.tab_id)\t\(.title)"')
fi

# Parse workspaces: "ws_name|has_wez|other_apps"
ws_data=$(i3-msg -t get_tree | jq -r '
  def rename: {
    "Vivaldi-stable": "Web browser",
    "Mailspring": "eMail",
    "Yazi": "File browser",
    "ticker": "Stocks"
  } as $names | $names[.] // .;
  [.. | objects | select(.type == "workspace") | select(.name != "__i3_scratch")] |
  sort_by(.name | try tonumber catch .) |
  .[] |
  {
    name: .name,
    has_wez: ([.. | objects | select(.window != null) | .window_properties.class]
              | map(select(. == "org.wezfurlong.wezterm")) | length > 0),
    other_apps: ([.. | objects | select(.window != null) | .window_properties.class
                  | select(. != "org.wezfurlong.wezterm") | rename] | unique | join(", "))
  } |
  "\(.name)|\(.has_wez)|\(.other_apps)"
')

# Build parallel arrays: display entries and actions ("ws_num" or "ws_num\ttab_id")
entries=()
actions=()

while IFS='|' read -r ws_name has_wez other_apps; do
  if [[ "$has_wez" == "true" ]] && (( ${#wez_tabs[@]} > 0 )); then
    for tab_entry in "${wez_tabs[@]}"; do
      tab_id="${tab_entry%%$'\t'*}"
      tab_title="${tab_entry#*$'\t'}"
      if [[ -n "$other_apps" ]]; then
        entries+=("${ws_name} : ${other_apps} | ${tab_title}")
      else
        entries+=("${ws_name} : ${tab_title}")
      fi
      actions+=("${ws_name}"$'\t'"${tab_id}")
    done
  else
    if [[ "$has_wez" == "true" ]]; then
      apps="${other_apps:+${other_apps}, }Terminal"
    else
      apps="$other_apps"
    fi
    entries+=("${ws_name}${apps:+ : ${apps}}")
    actions+=("${ws_name}"$'\t'"-")
  fi
done <<< "$ws_data"

selected_idx=$(printf "%s\n" "${entries[@]}" | \
  $SCRIPTS_PATH/rofi-run.sh -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "workspace" -matching prefix -format i)

[[ -z "$selected_idx" || "$selected_idx" == "-1" ]] && exit

action="${actions[$((selected_idx + 1))]}"
ws_num="${action%%$'\t'*}"
tab_id="${action#*$'\t'}"

$SCRIPTS_PATH/workspace-goto.sh "$ws_num"

[[ "$tab_id" != "-" ]] && wezterm cli activate-tab --tab-id "$tab_id" 2>/dev/null
