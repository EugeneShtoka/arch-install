#!/bin/zsh
if [ -z "$1" ]; then
	dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9'
    choice=$(ls $MUSIC_PATH -a | rofi -i -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
    if [[ -n $choice ]]; then
        package="${$(echo $choice | awk '{print $1}')##*/}"
        $SCRIPTS_PATH/app-search-and-install.sh $package
    fi
    pathToPlay=$MUSIC_PATH/$choice
else
    pathToPlay=$MUSIC_PATH/$1
fi

setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
