#!/bin/zsh

echo "`date` custom-scripts-pull" >> $LOG_PATH
cd $HOME
git reset --hard
git pull
chmod -R +x $SCRIPTS_PATH
$SCRIPTS_PATH/custom-scripts-delete-license-and-readme.sh
$SCRIPTS_PATH/zsh-reload-config.sh

