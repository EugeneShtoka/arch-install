#!/bin/bash

#echo "`date` auto-sync-scripts" >> $HOME/.scripts.log
inotifywait -q -r -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $HOME/.zshrc $HOME/.env $HOME/.config/hypr/hyprland.conf $HOME/.config/systemd/user/start-up-routine.service $HOME/.gitignore $ZSHFN_PATH $SCRIPTS_PATH | while read DIR EVENT FILE
do
    echo "`date` auto-sync-scripts $EVENT on $DIR$FILE" >> $HOME/scripts.log
    $SCRIPTS_PATH/custom-scripts-push.sh
done