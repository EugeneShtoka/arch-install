#!/bin/zsh

prefix="$HOME/dev/work"
current_dir=$PWD

if [[ $current_dir == $prefix* ]]; then
  first_folder="${current_dir#$prefix/}"
  first_folder="${first_folder%%/*}"  
  setsid vivaldi-snapshot "https://gitlab.com/buildos/$first_folder" &>/dev/null
else
  setsid vivaldi-snapshot "https://gitlab.com/buildos/" &>/dev/null
fi