#!/bin/bash

#echo "`date` launch-silently $1 $2" >> $LOG_PATHa
hyprctl dispatch exec '[workspace 2 silent]' slack




hyprctl dispatch movetoworkspacesilent 2,zoom  