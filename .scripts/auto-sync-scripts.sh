#!/bin/bash

#echo "`date` auto-sync-scripts" >> $LOG_PATH
inotifywait -q -r -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $HOME/.zshrc $HOME/.env $HOME/.config/i3 $HOME/.config/autokey $HOME/.config/systemd/user/start-up-routine.service $HOME/.gitignore $ZSHFN_PATH $SCRIPTS_PATH | while read DIR EVENT FILE
do
    echo "`date` auto-sync-scripts $EVENT on $DIR$FILE" >> $SCRIPTS_PATH
    $SCRIPTS_PATH/custom-scripts-push.sh
done