#!/bin/zsh

for file in $MUSIC_PATH/**/*; do
    str=$(file $file)
    parts=(${(s/,/)str})
    echo $parts[1] $parts[2] $parts[3] $parts[4] $parts[5] $parts[6] $parts[7]
done
