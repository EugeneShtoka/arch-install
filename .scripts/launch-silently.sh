#!/bin/bash

echo "`date` launch-silently $1 $2" >> $HOME/scripts.log
hyprctl dispatch exec [titleworkspace 2 silent] $2