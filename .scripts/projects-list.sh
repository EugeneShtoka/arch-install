#!/bin/zsh

grep -oP '(?<=alias )[a-z,-]*(?==)' $SCRIPTS_PATH/aliases-projects.sh
