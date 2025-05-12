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

# --- Configuration ---
rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme='style-9-wide'
# Define the playlist file extension (change this to your actual extension like .m3u, .pls, etc.)
# Use lowercase here if using -iname for case-insensitivity.
playlist_extension="m3u" # Example: Use "m3u" for files ending in ".m3u" or ".M3U"
# ---------------------

# Variable to store the directory to search
search_path=""

# Determine the search path based on the argument $1
if [[ -n "$1" ]]; then
    # Argument $1 is provided, use it as the potential search path
    if [[ -d "$1" ]]; then
        # If $1 is a valid directory, use it
        search_path="$1"
    else
        # If $1 is provided but is not a directory, print an error and exit
        echo "Error: Provided argument '$1' is not a valid directory."
        exit 1
    fi
else
    # No argument provided, default to MUSIC_PATH
    if [ -z "$MUSIC_PATH" ]; then
        echo "Error: MUSIC_PATH environment variable is not set and no directory argument was provided."
        exit 1
    elif [[ ! -d "$MUSIC_PATH" ]]; then
         # If MUSIC_PATH is set but is not a valid directory, print an error and exit
         echo "Error: MUSIC_PATH environment variable is set to '$MUSIC_PATH', which is not a valid directory."
         exit 1
    else
        # MUSIC_PATH is set and is a valid directory, use it as default
        search_path="$MUSIC_PATH"
    fi
fi

# --- Start of the main Rofi Selection Logic ---
# This block now operates on the determined search_path

# Declare an associative array to map the display names (shown in Rofi) to their full paths
declare -A playlist_map
# Declare a standard array to hold the display names for Rofi
declare -a playlist_options

# Find playlist files recursively starting from the determined search_path
# -type f filters for files
# -iname "*.${playlist_extension}" searches for files ending in the extension, case-insensitively
# -print0 prints the full path of each found file, terminated by a null character (safer for spaces/special chars)
find "$search_path" -type f -iname "*.${playlist_extension}" -print0 |
while IFS= read -r -d '' fullpath; do
    # Derive the path relative to the search_path
    # This is used to create a potentially more unique display name in Rofi
    # Handle the case where search_path is the root directory "/"
    if [[ "$search_path" == "/" ]]; then
        relativepath="${fullpath#/}" # Remove only the leading slash if search_path is root
    else
        relativepath="${fullpath#"$search_path"/}" # Remove the $search_path/ prefix
    fi

    # Create the display name by removing the file extension from the relative path
    # ${variable%.pattern} removes the shortest match of pattern from the end
    display_name="${relativepath%.*}"

    # Handle potential empty display_name if the relative path was just the extension (e.g., ".m3u")
    # or if stripping the extension resulted in an empty string for some edge case.
    # In such cases, use the full relative path as the display name.
     if [[ -z "$display_name" && -n "$relativepath" ]]; then
        display_name="$relativepath"
    fi


    # Store the mapping: display name -> full path
    playlist_map["$display_name"]="$fullpath"

    # Add the display name to the list for Rofi
    playlist_options+=("$display_name")

done # The find output is piped directly into the while loop

# Check if any playlists were found in the search path
if [ ${#playlist_options[@]} -eq 0 ]; then
    echo "No playlists found with extension .${playlist_extension} in '$search_path' or its subdirectories."
    # Optional: Add a desktop notification if desired
    # notify-send "Music Player" "No playlists found in '$search_path'."
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
