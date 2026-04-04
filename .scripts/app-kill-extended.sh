#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme="style-9-narrow"

source "$SCRIPTS_PATH/app-names.sh"
i3_tree=$(i3-msg -t get_tree)

# GUI app classes from i3 (excluding wezterm)
gui_classes=$(echo "$i3_tree" | jq -r '
  [.. | objects | select(.window != null)
    | select(.window_properties.class != "org.wezfurlong.wezterm")
    | .window_properties.class] | unique | .[]
')

# User background processes, filtered to exclude shells/system/i3 infra
exclude='^(zsh|bash|sh|fish|dash|ps|grep|awk|sed|cat|tail|head|tee|xargs|
  systemd|dbus-daemon|dbus-broker|
  pipewire|pipewire-pulse|wireplumber|pulseaudio|
  Xorg|xorg|xinit|x11|xdpyinfo|xdg-desktop-portal|xdg-permission|
  i3|i3bar|dunst|polybar|picom|compton|rofi|
  wezterm-gui|wezterm|wezterm-mux|
  ssh-agent|gpg-agent|gnome-keyring|
  at-spi2|gvfs|dconf|gdbus|glib|gio|
  python3|node|cargo|rustc|
  tmux|screen)$'

bg_procs=$(ps --user "$USER" -o comm= | sort -u | grep -vE "${exclude//[$'\n']/}")

entries=()
actions=()

rename_app() {
  case "$1" in
    "Vivaldi-stable") echo "Web browser" ;;
    "NeoMutt")        echo "Email" ;;
    "Yazi")           echo "File browser" ;;
    "ticker")         echo "Stocks" ;;
    *)                echo "$1" ;;
  esac
}

# Add GUI apps
while IFS= read -r class; do
  [[ -z "$class" ]] && continue
  entries+=("$(rename_app "$class")")
  actions+=("gui"$'\t'"$class")
done <<< "$gui_classes"

# Add background processes not already represented by a GUI entry
while IFS= read -r proc; do
  [[ -z "$proc" ]] && continue
  # Skip if already covered by a gui class (case-insensitive)
  already=0
  for c in ${(f)gui_classes}; do
    [[ "${c:l}" == "${proc:l}" ]] && already=1 && break
  done
  [[ $already -eq 1 ]] && continue
  entries+=("$proc")
  actions+=("proc"$'\t'"$proc")
done <<< "$bg_procs"

[[ ${#entries[@]} -eq 0 ]] && exit

selected_idx=$(printf "%s\n" "${entries[@]}" | \
  $SCRIPTS_PATH/rofi-run.sh -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "kill" -matching fuzzy -i -format i)

[[ -z "$selected_idx" || "$selected_idx" == "-1" ]] && exit

action="${actions[$((selected_idx + 1))]}"
action_type="${action%%$'\t'*}"
target="${action#*$'\t'}"

if [[ "$action_type" == "gui" ]]; then
  xdotool search --class "$target" 2>/dev/null | xargs -I{} xdotool windowclose {} 2>/dev/null
  sleep 0.3
  pkill -if "$target" 2>/dev/null
else
  pkill -x "$target" 2>/dev/null
fi
