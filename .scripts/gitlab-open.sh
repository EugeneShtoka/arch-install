#!/bin/zsh

# Set the required prefix
prefix="$HOME/dev/work"

# Get the current directory
current_dir=$PWD

# Check if the current directory starts with the prefix
if [[ $current_dir == $prefix* ]]; then
  # Extract the first folder after the prefix
  first_folder="${current_dir#$prefix/}"
  first_folder="${first_folder%%/*}"  

  echo "Current directory starts with the prefix."
  echo "First folder after the prefix: $first_folder"
else
  echo "Current directory does not start with the prefix."
fi