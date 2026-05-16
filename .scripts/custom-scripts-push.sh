#!/bin/zsh

echo "`date` custom-scripts-push" >> $LOG_PATH
$SCRIPTS_PATH/ssh-init.sh
cd $HOME
git add .
[[ -z $(git diff --cached --name-only) ]] && return

git commit -m update
git push
