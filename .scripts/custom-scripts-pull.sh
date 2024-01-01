#!/bin/bash

echo "`date` custom-scripts-pull" >> $HOME/scripts.log
cd $HOME
git reset --hard
git pull
chmod -R +x $SCRIPTS_PATH
$SCRIPTS_PATH/custom-scripts-delete-license-and-readme.sh

