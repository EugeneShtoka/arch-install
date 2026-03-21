#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-wide"

i3_tree=$(i3-msg -t get_tree)
wez_json=$(wezterm cli list --format json 2>/dev/null) || wez_json='[]'

# One row per tab sorted by tab_id: "window_id\ttab_id\ttab_title"
# tab_title is already formatted by format-tab-title (respects set-tab-title)
wez_tabs=$(echo "$wez_json" | jq -r '
  group_by(.tab_id) | map(.[0]) | sort_by(.tab_id) |
  .[] | "\(.window_id)\t\(.tab_id)\t\(if .tab_title != "" then .tab_title else .title end)"
')

# Wezterm windows from i3 tree: "ws_name\tpane_title"
# i3 name format is "[N/M] pane_title" — strip the prefix to get raw pane_title
i3_wez_wins=$(echo "$i3_tree" | jq -r '
  [.. | objects | select(.type == "workspace") | select(.name != "__i3_scratch")] |
  .[] | . as $ws |
  [.. | objects | select(.window != null)
    | select(.window_properties.class == "org.wezfurlong.wezterm")] |
  .[] | "\($ws.name)\t\(.name)"
' | sed 's/\t\[[0-9]*\/[0-9]*\] /\t/')

# pane_title -> window_id lookup (from wezterm list, title = raw pane title)
wez_pane_to_winid=$(echo "$wez_json" | jq -r '.[] | "\(.title)\t\(.window_id)"' | sort -u)

# Build ws_name -> space-separated window_ids (supports multiple wezterm windows per ws)
typeset -A ws_to_winids
while IFS=$'\t' read -r ws_name pane_title; do
  winid=$(echo "$wez_pane_to_winid" | awk -F'\t' -v t="$pane_title" '$1 == t {print $2; exit}')
  if [[ -n "$winid" ]]; then
    ws_to_winids[$ws_name]+="${ws_to_winids[$ws_name]:+ }$winid"
  fi
done <<< "$i3_wez_wins"

tabs_for_winids() {
  echo "$wez_tabs" | awk -F'\t' -v ids="$1" '
    BEGIN { n = split(ids, a, " "); for (i=1; i<=n; i++) map[a[i]]=1 }
    $1 in map { print $2"\t"$3 }
  '
}

# i3 workspaces: "ws_name|has_wez|other_apps"
ws_data=$(echo "$i3_tree" | jq -r '
  def rename: {
    "Vivaldi-stable": "Web browser",
    "Mailspring": "eMail",
    "Yazi": "File browser",
    "ticker": "Stocks"
  } as $names | $names[.] // .;
  [.. | objects | select(.type == "workspace") | select(.name != "__i3_scratch")] |
  sort_by(.name | try tonumber catch .) | .[] |
  {
    name: .name,
    has_wez: ([.. | objects | select(.window != null) | .window_properties.class]
              | map(select(. == "org.wezfurlong.wezterm")) | length > 0),
    other_apps: ([.. | objects | select(.window != null) | .window_properties.class
                  | select(. != "org.wezfurlong.wezterm") | rename] | unique | join(", "))
  } |
  "\(.name)|\(.has_wez)|\(.other_apps)"
')

entries=()
actions=()

while IFS='|' read -r ws_name has_wez other_apps; do
  if [[ "$has_wez" == "true" ]] && [[ "$wez_json" != "[]" ]]; then
    winids="${ws_to_winids[$ws_name]}"
    if [[ -n "$winids" ]]; then
      tabs=$(tabs_for_winids "$winids")
    else
      tabs=$(echo "$wez_tabs" | awk -F'\t' '{print $2"\t"$3}')  # fallback: all tabs
    fi

    tab_num=1
    while IFS=$'\t' read -r tab_id tab_title; do
      [[ -z "$tab_id" ]] && continue
      if [[ -n "$other_apps" ]]; then
        label="${ws_name}${tab_num} : ${other_apps} | ${tab_title}"
      else
        label="${ws_name}${tab_num} : ${tab_title}"
      fi
      entries+=("$label")
      actions+=("${ws_name}"$'\t'"${tab_id}")
      (( tab_num++ ))
    done <<< "$tabs"
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
