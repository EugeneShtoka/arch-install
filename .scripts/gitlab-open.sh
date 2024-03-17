#!/bin/zsh

script_path="${0:a}"
echo "path $PWD"

script_dir="${script_path:h}"
echo "The script is located in: $script_dir"