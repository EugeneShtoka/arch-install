#!/bin/sh
multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

start_dir="${path:-$HOME}"
sentinel="/tmp/yazi-chooser-done-$$"

wezterm start --always-new-process -- sh -c "yazi --chooser-file=\"$out\" \"$start_dir\"; touch \"$sentinel\""

while [ ! -f "$sentinel" ]; do
    sleep 0.2
done
rm -f "$sentinel"
