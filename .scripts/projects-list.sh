#!/bin/zsh

grep -oP '(?<=alias )[a-z0-9,-]*(?==)' $SCRIPTS_PATH/aliases-projects.sh
