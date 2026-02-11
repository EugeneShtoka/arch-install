#!/bin/zsh

grep -oP '(?<=alias )[a-z,-]*(?==)' $SCRIPTS_PATH/vim-projects-aliases.sh
