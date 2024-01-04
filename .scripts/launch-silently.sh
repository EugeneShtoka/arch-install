#!/bin/bash

echo "`date` launch-silently $1 $2" >> $HOME/scripts.log
hyprctl dispatch exec [workspace 2silent] $2