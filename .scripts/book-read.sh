#!/bin/zsh
dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9-columns'
choice=$(ls $LIBRARY_PATH -a | grep -v '\.\.' | rofi -i -theme ${dir}/${theme}.rasi -dmenu -matching prefix)

if [ -z "$1" ]; then
	current_path=$LIBRARY_PATH
else
    current_path=$LIBRARY_PATH/$1
fi

while true; do
    local choice=$(ls -a "$current_path" | grep -v '\.\.' | rofi -i -theme "$dir/$theme.rasi" -dmenu -matching prefix)

    if [[ -z "$choice" ]]; then  # User cancelled
        return 1 
    fi

    local full_path="$current_path/$choice"
    if [[ -d "$full_path" ]]; then
        current_path="$full_path"
    elif [[ -f "$full_path" ]]; then
        setsid koodo-reader "$full_path" >/dev/null 2>&1 & 
        return 0  # Success
    fi
done

    if [[ -n $choice ]]; then
        current_path=$LIBRARY_PATH/$choice
        setsid koodo-reader $pathToPlay > /dev/null 2>&1 &
    fi
else
    pathToPlay=$LIBRARY_PATH/$1
    setsid koodo-reader $pathToPlay > /dev/null 2>&1 &

