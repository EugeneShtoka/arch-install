#!/usr/bin/env bash

if [[ "$6" == "1" ]]; then
  set -x
fi

# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# Inputs:
# 1. "1" if multiple files can be chosen, "0" otherwise.
# 2. "1" if a directory should be chosen, "0" otherwise.
# 3. "0" if opening files was requested, "1" if writing to a file was
#    requested. For example, when uploading files in Firefox, this will be "0".
#    When saving a web page in Firefox, this will be "1".
# 4. If writing to a file, this is recommended path provided by the caller. For
#    example, when saving a web page in Firefox, this will be the recommended
#    path Firefox provided, such as "~/Downloads/webpage_title.html".
#    Note that if the path already exists, we keep appending "_" to it until we
#    get a path that does not exist.
# 5. The output path, to which results should be written.
# 6. "1" if log level >= DEBUG, "0" otherwise.
#
# Output:
# The script should print the selected paths to the output path (argument #5),
# one path per line.
# If nothing is printed, then the operation is assumed to have been canceled.

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"
cmd="/usr/bin/yazi"
# "wezterm start --always-new-process" if you use wezterm
if [ "$save" = "1" ]; then
  TITLE="Save File:"
elif [ "$directory" = "1" ]; then
  TITLE="Select Directory:"
else
  TITLE="Select File:"
fi

quote_string() {
  local input="$1"
  echo "'${input//\'/\'\\\'\'}'"
}

termcmd="${TERMCMD:-/usr/bin/wezterm start --always-new-process}"

tmpfile=""

cleanup() {
  if [ -f "$tmpfile" ]; then
    /usr/bin/rm "$tmpfile" || :
  fi
  if [ "$save" = "1" ] && [ ! -s "$out" ]; then
    /usr/bin/rm "$path" || :
  fi
}

trap cleanup EXIT HUP INT QUIT ABRT TERM

# Returns 0 if safe to overwrite: file absent, empty, or tiny+freshly created
check_safe_to_save() {
  local target="$1" size mtime age
  [ ! -e "$target" ] && return 0
  size=$(stat -c%s "$target" 2>/dev/null) || return 1
  [ "$size" = "0" ] && return 0
  mtime=$(stat -c%Y "$target" 2>/dev/null) || return 1
  age=$(( $(date +%s) - mtime ))
  [ "$size" -le 512 ] && [ "$age" -le 30 ] && return 0
  return 1
}

zenity_cobalt2() {
  XDG_CONFIG_HOME="$HOME/.config/zenity-cobalt2" ADW_DEBUG_COLOR_SCHEME=prefer-dark zenity "$@"
}

write_path_checked() {
  local target="$1"
  if check_safe_to_save "$target"; then
    printf '%s\n' "$target" > "$out"
  else
    zenity_cobalt2 --question --no-wrap \
      --title="File already exists" \
      --text="<b>$(basename "$target")</b> already has content.\nOverwrite it?" \
      --ok-label="Overwrite" --cancel-label="Cancel" \
      && printf '%s\n' "$target" > "$out"
  fi
}

if [ "$save" = "1" ]; then
  suggest_name=$(basename "$path")
  { [ -z "$suggest_name" ] || [ "$suggest_name" = "." ] || [ "$suggest_name" = "(null)" ]; } && suggest_name="file-$(date +%s)"

  # Copy suggested filename to clipboard for easy empty-file creation
  printf '%s' "$suggest_name" | xclip -selection clipboard

  # Offer quick save locations or custom location via yazi
  choice=$(zenity_cobalt2 --list \
    --title="Save file" \
    --text="Save <b>$suggest_name</b> to:" \
    --column="Location" --hide-header \
    --height=380 --width=400 \
    "Downloads" "Music" "Pictures" "Documents" "Torrents" "Custom location")

  case "$choice" in
    "Downloads")  write_path_checked "$HOME/Downloads/$suggest_name" ;;
    "Music")      write_path_checked "$HOME/Music/$suggest_name" ;;
    "Pictures")   write_path_checked "$HOME/Pictures/$suggest_name" ;;
    "Documents")  write_path_checked "$HOME/Documents/$suggest_name" ;;
    "Torrents")   write_path_checked "$HOME/Torrents/$suggest_name" ;;
    "Custom location")
      tmpfile=$(/usr/bin/mktemp)
      suggest_dir=$(dirname "$path")
      eval "$termcmd -- $cmd $(quote_string "--chooser-file=$tmpfile") $(quote_string "$suggest_dir")"
      if [ -s "$tmpfile" ]; then
        selected_file=$(/usr/bin/head -n 1 "$tmpfile")
        write_path_checked "$selected_file"
        path="$selected_file"
      fi
      ;;
  esac

elif [ "$directory" = "1" ]; then
  # upload files from a directory
  # Use this if you want to select folder by 'quit' function in yazi.
  set -- --cwd-file="$(quote_string "$out")" "$(quote_string "$path")"
  # NOTE: Use this if you want to select folder by enter a.k.a yazi keybind for 'open' funtion ('run = "open") .
  # set -- --chooser-file="$out" "$path"
  eval "$termcmd -- $cmd $@"
elif [ "$multiple" = "1" ]; then
  # upload multiple files
  set -- --chooser-file="$(quote_string "$out")" "$(quote_string "$path")"
  eval "$termcmd -- $cmd $@"
else
  # upload only 1 file
  set -- --chooser-file="$(quote_string "$out")" "$(quote_string "$path")"
  eval "$termcmd -- $cmd $@"
fi
