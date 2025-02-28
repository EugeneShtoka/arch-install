#!/bin/zsh

notify-send \"wrapper\" \"<span font='15px'>$(ssh-add -l)</span>\" --icon \" \" -r 101037 
setsid zsh -c "$SCRIPTS_PATH/notes-start.sh" &>/dev/null