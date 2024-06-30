#!/bin/zsh

echo "`date` custom-scripts-auto-sync" >> $LOG_PATH

inotifywait -q -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $HOME/.zshrc $HOME/.env $HOME/.gitignore $HOME/.config/i3 $HOME/.config/systemd/user $SCRIPTS_PATH $SERVICES_PATH | while read DIR EVENT FILE
do
    echo "`date` custom-scripts-auto-sync $EVENT on $DIR$FILE" >> $LOG_PATH
    $SCRIPTS_PATH/custom-scripts-push.sh
done

inotifywait -q -r -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $HOME/.config/autokey | while read DIR EVENT FILE
do
    echo "`date` custom-scripts-auto-sync autokey $EVENT on $DIR$FILE" >> $LOG_PATH
    $SCRIPTS_PATH/custom-scripts-push.sh
done

inotifywait -q -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $HOME/.config/copyq/copyq-commands.ini $HOME/.config/copyq/copyq-filter.ini $HOME/.config/copyq/copyq.conf $HOME/.config/copyq/themes | while read DIR EVENT FILE
do
    echo "`date` custom-scripts-auto-sync copyq $EVENT on $DIR$FILE" >> $LOG_PATH
    $SCRIPTS_PATH/custom-scripts-push.sh
done
