#!/bin/zsh

grep -oP '(?<=alias )[a-z,-]*(?==)' $SCRIPTS_PATH/games-aliases.sh
