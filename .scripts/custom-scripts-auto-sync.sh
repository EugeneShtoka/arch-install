#!/bin/zsh

echo "`date` custom-scripts-auto-sync" >> $LOG_PATH

inotifywait -q -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $HOME/.zshrc $HOME/.env $HOME/.config/i3 $HOME/.config/systemd/user $HOME/.gitignore $ZSHFN_PATH $SCRIPTS_PATH $SERVICES_PATH | while read DIR EVENT FILE
do
    echo "`date` custom-scripts-auto-sync $EVENT on $DIR$FILE" >> $LOG_PATH
    $SCRIPTS_PATH/custom-scripts-push.sh
done

inotifywait -q -r -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $HOME/.config/autokey | while read DIR EVENT FILE
do
    echo "`date` custom-scripts-auto-sync $EVENT on $DIR$FILE" >> $LOG_PATH
    $SCRIPTS_PATH/custom-scripts-push.sh
done
