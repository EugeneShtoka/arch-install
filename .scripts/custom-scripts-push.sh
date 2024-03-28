#!/bin/zsh

echo "`date` custom-scripts-push" >> $LOG_PATH
$SCRIPTS_PATH/ssh-init.sh
cd $HOME
git add .

git commit -m update
git push
