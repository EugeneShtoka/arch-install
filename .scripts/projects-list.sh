#!/bin/zsh

grep -oP '(?<=nvim_project )\S+ +\S+' $SCRIPTS_PATH/aliases-projects.sh \
  | awk '{print $1 "|" $2}' \
  | envsubst
