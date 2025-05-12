#!/bin/zsh

playlist_extension=".xspf"
if [ -z "$1" ]; then
	dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9-wide'
    choice=$(find "$MUSIC_PATH" -type f -name "*${playlist_extension}" -printf "%f\n" | sed "s/${playlist_extension}$//" | rofi -i -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
    if [[ -n $choice ]]; then
        pathToPlay="$MUSIC_PATH/$choice$playlist_extension"
        echo $pathToPlay
        setsid cvlc $pathToPlay > /dev/null 2>&1 &
    fi
else
    pathToPlay=$MUSIC_PATH/$1
    setsid cvlc $pathToPlay > /dev/null 2>&1 &
fi

#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme='style-9-wide'
playlist_extension="xspf"

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
    exit 0 # Exit gracefully if no playlists are found
fi

# Pipe the list of display names to Rofi (sorted for easier navigation)
# printf "%s\n" handles display names with spaces correctly
choice=$(printf "%s\n" "${playlist_options[@]}" | sort | rofi -i -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -matching prefix)

# Check if a choice was made by the user in Rofi (rofi returns empty if cancelled)
if [[ -n "$choice" ]]; then
    # Look up the full path using the chosen display name from the associative array
    pathToPlay="${playlist_map["$choice"]}"

    # Check if the lookup was successful (i.e., pathToPlay is not empty) and the file actually exists
    if [[ -n "$pathToPlay" && -f "$pathToPlay" ]]; then
         # Execute cvlc with the full, correct path in the background
         # setsid detaches the process from the terminal
         # > /dev/null 2>&1 redirects stdout and stderr to null
         # & runs the command in the background
         setsid cvlc "$pathToPlay" > /dev/null 2>&1 &
    else
        # This case should ideally not be reached unless the file was deleted after the menu was shown
        echo "Error: Could not retrieve full path for '$choice' or file not found: $pathToPlay"
        # Optional: Add a desktop notification for this error
        # notify-send "Music Player Error" "Could not play playlist: $choice"
    fi
# else: User cancelled Rofi (made no choice), do nothing.
fi

# --- End of Rofi Selection Logic ---

# The original 'else' block that handled playing a specific file passed as $1 is removed,
# as $1 is now used exclusively to specify the search directory for the menu.
