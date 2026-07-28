#!/bin/zsh
# Play a library folder/file through MPD (shuffled) and open the rmpc client.
# URIs are relative to MPD's music_directory (== $MUSIC_PATH).

play_uri() {
    local uri="$1"
    mpc -q clear
    mpc -q add "$uri"
    mpc -q random on
    mpc -q play
    $SCRIPTS_PATH/music-client.sh
}

if [ -z "$1" ]; then
    dir="$HOME/.config/rofi/launchers/type-4"
    theme='style-9-columns'
    choice=$(ls $MUSIC_PATH | $SCRIPTS_PATH/rofi-freq.sh music-play -i -theme ${dir}/${theme}.rasi -matching prefix)
    [[ -n $choice ]] && play_uri "$choice"
else
    play_uri "$1"
fi
