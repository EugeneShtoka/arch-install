#!/bin/zsh
if [[ "$1" == "--new" ]]; then
  setsid $BROWSER &>/dev/null
else
  $SCRIPTS_PATH/app-focus-or-launch.sh "Vivaldi-stable" $BROWSER
fi
