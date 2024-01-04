#!/bin/bash

echo "`date` launch-silently " >> $HOME/scripts.log
hyprctl dispatch exec [workspace $1 silent] $2