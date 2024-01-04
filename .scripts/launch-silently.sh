#!/bin/bash

echo "`date` custom-scripts-push" >> $HOME/scripts.log
hyprctl dispatch exec [workspace $1 silent] $2