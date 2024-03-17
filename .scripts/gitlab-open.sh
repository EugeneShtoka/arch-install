#!/bin/zsh

prefix="$HOME/dev/work"
current_dir=$PWD

if [[ $current_dir == $prefix* ]]; then
  first_folder="${current_dir#$prefix/}"
  first_folder="${first_folder%%/*}"  
  setsid vivaldi-snapshot "https://gitlab.com/buildos/$first_folder" &>/dev/null
  echo "Current directory starts with the prefix."
  echo "First folder after the prefix: $first_folder"
else
  echo "Current directory does not start with the prefix."
fi