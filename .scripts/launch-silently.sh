#!/bin/bash

echo "luanch-silently $1 $2"
echo "`date` custom-scripts-push" >> $HOME/scripts.log
hyprctl dispatch exec [workspace $1 silent] $2