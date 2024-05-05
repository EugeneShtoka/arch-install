#!/bin/zsh

for file in $MUSIC_PATH/**/*; do
    str=$(file $file)
    parts=(${(s/,/)str})
    echo $parts[1] $parts[5]
done
