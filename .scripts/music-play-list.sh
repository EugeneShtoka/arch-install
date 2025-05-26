#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme='style-9-wide'
playlist_extension="xspf"

search_path=""

if [[ -n "$1" ]]; then
    if [[ -d "$1" ]]; then
        search_path="$1"
    else
        notify-send "Music Player" "Provided argument '$1' is not a valid directory."
        exit 1
    fi
else
    if [ -z "$MUSIC_PATH" ]; then
        notify-send "Music Player" "MUSIC_PATH environment variable is not set and no directory argument was provided."
        exit 1
    elif [[ ! -d "$MUSIC_PATH" ]]; then
        notify-send "Music Player" "MUSIC_PATH environment variable is set to '$MUSIC_PATH', which is not a valid directory."
         exit 1
    else
        search_path="$MUSIC_PATH"
    fi
fi

declare -A playlist_map
declare -a playlist_options

find "$search_path" -type f -iname "*.${playlist_extension}" -print0 |
while IFS= read -r -d '' fullpath; do
    filename="${fullpath##*/}"
    display_name="${filename%.*}"
    
    playlist_map["$display_name"]="$fullpath"
    playlist_options+=("$display_name")

done

if [ ${#playlist_options[@]} -eq 0 ]; then
    notify-send "Music Player" "No playlists found in '$search_path'."
    exit 0
fi

choice=$(printf "%s\n" "${playlist_options[@]}" | sort | rofi -i -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -matching prefix)

if [[ -n "$choice" ]]; then
    $SCRIPTS_PATH/music-stop.sh
    pathToPlay="${playlist_map["$choice"]}"
    setsid cvlc "$pathToPlay" > /dev/null 2>&1 &
fi