#!/bin/bash

echo "`date` launch-silently $1 $2" >> $HOME/scripts.log
hyprctl dispatch -- exec '[title;workspace  silent]' $2