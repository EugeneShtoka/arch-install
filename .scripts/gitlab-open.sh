#!/bin/zsh

script_path="${0:a}"
echo "path $script_path"

script_dir="${script_path:h}"
echo "The script is located in: $script_dir"