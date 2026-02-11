#!/bin/zsh

grep -oP '(?<=alias )[a-z,-]*(?==)' $SCRIPTS_PATH/projects-aliases.sh
