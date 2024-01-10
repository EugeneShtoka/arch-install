#!/bin/bash

#echo "`date` work-setup" >> $LOG_PATH
hyprctl dispatch exec '[workspace 2 silent]' beeper
hyprctl dispatch exec '[workspace 2 silent]' $SCRIPTS_PATH/mailspring

hyprctl dispatch exec '[workspace 2 silent]' slack
hyprctl dispatch exec '[workspace 2 silent]' slack

hyprctl dispatch exec '[workspace 2 silent]' slack
hyprctl dispatch exec '[workspace 2 silent]' slack


hyprctl dispatch movetoworkspacesilent 2,zoom  