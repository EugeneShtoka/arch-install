#!/bin/zsh

grep -oP '(?<=nvim_project )[a-z0-9,-]+' $SCRIPTS_PATH/aliases-projects.sh
