#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9-columns'
choice=$(ls $DOWNLOAD_DIR | grep '.torrent' | rofi -i -theme ${dir}/${theme}.rasi -dmenu -matching prefix)

torrents=.config/torrents

if [[ -n $choice ]]; then
    torrentPath=$DOWNLOAD_DIR/"$choice"
    name=$choice #convert to more meaningful name with gemini
    newPath=$TORRENTS_DIR/"$name"
    mkdir "$newPath"
    newTorrentPath="$newPath"/file.torrent
    logPath="$newPath"/progress.log

    mv $torrentPath $newTorrentPath
    setsid transmission-cli "$newTorrentPath" -w Torrents -f $SCRIPTS_PATH/torrent-clean-up.sh "$name" > "$logPath" > /dev/null 2>&1 &
fi