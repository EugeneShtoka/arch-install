#!/bin/zsh
dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9-columns'

if [ -z "$1" ]; then
	current_path=$LIBRARY_PATH
else
    current_path=$LIBRARY_PATH/$1
fi

while true; do
    local choice=$(ls -a "$current_path" | rofi -i -theme "$dir/$theme.rasi" -dmenu -matching prefix)

    if [[ -z "$choice" ]]; then  # User cancelled
        return 1 
    fi

    local full_path="$current_path/$choice"
    echo $full_path
    if [[ -d "$full_path" ]]; then
        current_path="$full_path"
    elif [[ -f "$full_path" ]]; then
        setsid koodo-reader "$full_path" >/dev/null 2>&1 &
        return 0
    fi
done