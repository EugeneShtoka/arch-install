#!/bin/zsh
setsid zsh -c "env LANGUAGE=en_GB && /home/eugene/.scripts/ssh-init.sh && sleep 100 && notify-send \"test\" \"<span font='15px'>$(ssh-add -l)</span>\" --icon \" \" -r 101037 && obsidian" &>/dev/null

