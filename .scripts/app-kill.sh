#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-narrow"

i3_tree=$(i3-msg -t get_tree)

# Unique app classes from i3 windows, excluding wezterm
apps=$(echo "$i3_tree" | jq -r '
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

[[ -z "$apps" ]] && exit

entries=()
classes=()
while IFS=$'\t' read -r class display_name; do
  entries+=("$display_name")
  classes+=("$class")
done <<< "$apps"

selected_idx=$(printf "%s\n" "${entries[@]}" | \
  $SCRIPTS_PATH/rofi-run.sh -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "kill" -matching fuzzy -i -format i)

[[ -z "$selected_idx" || "$selected_idx" == "-1" ]] && exit

class="${classes[$((selected_idx + 1))]}"

xdotool search --class "$class" 2>/dev/null | xargs -I{} xdotool windowclose {} 2>/dev/null
sleep 0.3
pkill -if "$class" 2>/dev/null
