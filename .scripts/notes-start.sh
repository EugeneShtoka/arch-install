#!/bin/zsh

export env LANGUAGE=en_GB
. /home/eugene/.scripts/ssh-init.sh 
notify-send "start" "<span font='15px'>$(ssh-add -l)</span>" --icon " " -r 101037 
obsidian