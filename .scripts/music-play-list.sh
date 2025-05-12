#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme='style-9-wide'
playlist_extension="xspf-ppppp"

search_path=""

if [[ -n "$1" ]]; then
    if [[ -d "$1" ]]; then
        search_path="$1"
    else
        echo "Error: Provided argument '$1' is not a valid directory."
        exit 1
    fi
else
    if [ -z "$MUSIC_PATH" ]; then
        echo "Error: MUSIC_PATH environment variable is not set and no directory argument was provided."
        exit 1
    elif [[ ! -d "$MUSIC_PATH" ]]; then
         echo "Error: MUSIC_PATH environment variable is set to '$MUSIC_PATH', which is not a valid directory."
         exit 1
    else
        search_path="$MUSIC_PATH"
    fi
fi

declare -A playlist_map
declare -a playlist_options

find "$search_path" -type f -iname "*.${playlist_extension}" -print0 |
while IFS= read -r -d '' fullpath; do
    if [[ "$search_path" == "/" ]]; then
        relativepath="${fullpath#/}"
    else
        relativepath="${fullpath#"$search_path"/}"
    fi

    display_name="${relativepath%.*}"

    playlist_map["$display_name"]="$fullpath"
    playlist_options+=("$display_name")

done

if [ ${#playlist_options[@]} -eq 0 ]; then
    echo "No playlists found with extension .${playlist_extension} in '$search_path' or its subdirectories."
    notify-send "Music Player" "No playlists found in '$search_path'."
    exit 0
fi

choice=$(printf "%s\n" "${playlist_options[@]}" | sort | rofi -i -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -matching prefix)

if [[ -n "$choice" ]]; then
    pathToPlay="${playlist_map["$choice"]}"
    if [[ -n "$pathToPlay" && -f "$pathToPlay" ]]; then
         setsid cvlc "$pathToPlay" > /dev/null 2>&1 &
    else
        echo "Error: Could not retrieve full path for '$choice' or file not found: $pathToPlay"
        notify-send "Music Player" "Could not play playlist: $choice"
    fi
fi

# --- End of Rofi Selection Logic ---

# The original 'else' block that handled playing a specific file passed as $1 is removed,
# as $1 is now used exclusively to specify the search directory for the menu.
