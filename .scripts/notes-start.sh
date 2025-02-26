#!/bin/zsh
env LANGUAGE=en_GB 
/home/eugene/.scripts/ssh-init.sh 
notify-send test <span font='15px'>$(ssh-add -l)</span> --icon " " -r 101037
obsidian

