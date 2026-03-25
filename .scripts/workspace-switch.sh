#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-wide"

i3_tree=$(i3-msg -t get_tree)
wez_json=$(wezterm cli list --format json 2>/dev/null) || wez_json='[]'

# One row per tab sorted by tab_id: "window_id\ttab_id\ttab_title"
wez_tabs=$(echo "$wez_json" | jq -r '
  group_by(.tab_id) | map(.[0]) | sort_by(.tab_id) |
  .[] | "\(.window_id)\t\(.tab_id)\t\(if .tab_title != "" then .tab_title else .title end)"
')

# pane_title -> window_id lookup
wez_pane_to_winid=$(echo "$wez_json" | jq -r '.[] | "\(.title)\t\(.window_id)"' | sort -u)

# Build ws_name -> space-separated wezterm window_ids
typeset -A ws_to_winids
while IFS=$'\t' read -r ws_name pane_title; do
  [[ -z "$ws_name" ]] && continue
  winid=$(echo "$wez_pane_to_winid" | awk -F'\t' -v t="$pane_title" '$1 == t {print $2; exit}')
  [[ -n "$winid" ]] && ws_to_winids[$ws_name]+="${ws_to_winids[$ws_name]:+ }$winid"
done < <(echo "$i3_tree" | jq -r '
  [.. | objects | select(.type == "workspace") | select(.name != "__i3_scratch")] |
  .[] | . as $ws |
  [.. | objects | select(.window != null)
    | select(.window_properties.class == "org.wezfurlong.wezterm")] |
  .[] | "\($ws.name)\t\(.name)"
' | sed 's/\t\[[0-9]*\/[0-9]*\] /\t/')

tabs_for_winids() {
  echo "$wez_tabs" | awk -F'\t' -v ids="$1" '
    BEGIN { n = split(ids, a, " "); for (i=1; i<=n; i++) map[a[i]]=1 }
    $1 in map { print $2"\t"$3 }
  '
}

# All i3 windows sorted by workspace: "ws\tcon_id\tclass\tapp_name\ttitle"
i3_wins=$(echo "$i3_tree" | jq -r '
  def rename: {
    "Vivaldi-stable": "Web browser",
    "Mailspring": "eMail",
    "Yazi": "File browser",
    "ticker": "Stocks"
  } as $names | $names[.] // .;
  [.. | objects | select(.type == "workspace") | select(.name != "__i3_scratch")] |
  sort_by(.name | try tonumber catch .) | .[] | . as $ws |
  [.. | objects | select(.window != null)] | .[] |
  "\($ws.name)\t\(.id)\t\(.window_properties.class)\t\(.window_properties.class | rename)"
')

entries=()
actions=()
typeset -A ws_wez_done

while IFS=$'\t' read -r ws_name con_id class app_name i3_title; do
  [[ -z "$ws_name" ]] && continue

  if [[ "$class" == "org.wezfurlong.wezterm" ]]; then
    # Add all wezterm tabs for this workspace once
    [[ -n "${ws_wez_done[$ws_name]}" ]] && continue
    ws_wez_done[$ws_name]=1
    winids="${ws_to_winids[$ws_name]}"
    if [[ -n "$winids" ]]; then
      tabs=$(tabs_for_winids "$winids")
    else
      tabs=$(echo "$wez_tabs" | awk -F'\t' '{print $2"\t"$3}')
    fi
    while IFS=$'\t' read -r tab_id tab_title; do
      [[ -z "$tab_id" ]] && continue
      entries+=("${ws_name} : ${tab_title}")
      actions+=("wez"$'\t'"${ws_name}"$'\t'"${tab_id}")
    done <<< "$tabs"
  else
    entries+=("${ws_name} : ${app_name}")
    actions+=("i3"$'\t'"${con_id}")
  fi
done <<< "$i3_wins"

[[ ${#entries[@]} -eq 0 ]] && exit

selected_idx=$(printf "%s\n" "${entries[@]}" | \
  $SCRIPTS_PATH/rofi-run.sh -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "workspace" -matching prefix -format i)

[[ -z "$selected_idx" || "$selected_idx" == "-1" ]] && exit

action="${actions[$((selected_idx + 1))]}"
action_type="${action%%$'\t'*}"
rest="${action#*$'\t'}"

if [[ "$action_type" == "wez" ]]; then
  ws_num="${rest%%$'\t'*}"
  tab_id="${rest#*$'\t'}"
  $SCRIPTS_PATH/workspace-goto.sh "$ws_num"
  wezterm cli activate-tab --tab-id "$tab_id" 2>/dev/null
else
  i3-msg "[con_id=${rest}] focus"
fi
