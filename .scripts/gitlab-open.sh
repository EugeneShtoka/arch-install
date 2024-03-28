#!/bin/zsh

current_dir=$PWD

if [[ $current_dir == $WORK_REPOS_PATH* ]]; then
  first_folder="${current_dir#$WORK_REPOS_PATH/}"
  first_folder="${first_folder%%/*}"  
  setsid vivaldi-snapshot "https://gitlab.com/buildos/$first_folder" &>/dev/null
else
  setsid vivaldi-snapshot "https://gitlab.com/buildos/" &>/dev/null
fi