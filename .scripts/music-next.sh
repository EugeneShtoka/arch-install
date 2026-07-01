#!/bin/zsh

dbus-send --session --type=method_call --dest="org.mpris.MediaPlayer2.mpv" "/org/mpris/MediaPlayer2" "org.mpris.MediaPlayer2.Player.Next" >/dev/null
