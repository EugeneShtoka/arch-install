#!/bin/zsh

grep -oP '(?<=alias )[a-z,-]*(?==)' $SCRIPTS_PATH/aliases-games.sh
