#!/bin/zsh
# Pick an MPD stored playlist via rofi, load it into the queue (in order) and
# open the rmpc client.

source $SCRIPTS_PATH/notify-lib.sh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme='style-9-wide'

# MPD stored playlists (.m3u under playlist_directory).
playlists=$(mpc lsplaylists 2>/dev/null)

if [[ -z "$playlists" ]]; then
    notify_send "Music Player" "No MPD playlists found. Run music-playlists-convert.sh?"
    exit 0
fi

choice=$(printf "%s\n" "$playlists" | $SCRIPTS_PATH/rofi-freq.sh music-play-list -i -theme "${rofi_dir}/${rofi_theme}.rasi" -matching prefix)

if [[ -n "$choice" ]]; then
    mpc -q clear
    mpc -q random off
    mpc -q load "${choice%$'\n'}"
    mpc -q play
    $SCRIPTS_PATH/music-client.sh
fi
