#!/bin/zsh

source ~/.env

echo "`date` custom-scripts-auto-sync" >> $LOG_PATH
$SCRIPTS_PATH/ssh-init.sh
cd $HOME

git add .
[[ -n $(git diff --cached --name-only) ]] && git commit -m update

git fetch
git rebase origin/main
git push

chmod -R +x $SCRIPTS_PATH

$SCRIPTS_PATH/zsh-reload-config.sh
