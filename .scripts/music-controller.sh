#!/bin/bash

dbus-send --session --type=method_call --dest="org.mpris.MediaPlayer2.vlc" "/org/mpris/MediaPlayer2" "org.mpris.MediaPlayer2.Player.PlayPause" >/dev/null
