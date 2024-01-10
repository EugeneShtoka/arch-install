#!/bin/bash

#echo "`date` work-setup" >> $LOG_PATH
hyprctl dispatch exec '[workspace 2 silent]' beeper
hyprctl dispatch exec '[workspace 2 silent]' $SCRIPTS_PATH/mailspring-start.sh

hyprctl dispatch exec '[workspace 2 silent]' zoom
hyprctl dispatch exec '[workspace 2 silent]' slack

hyprctl dispatch exec '[workspace 2 silent]' google-chrome-stable
hyprctl dispatch exec '[workspace 2 silent]' code


hyprctl dispatch movetoworkspacesilent 1, beeper
hyprctl dispatch movetoworkspacesilent 1, beeper

hyprctl dispatch movetoworkspacesilent 1, zoom
hyprctl dispatch movetoworkspacesilent 1, slack

hyprctl dispatch movetoworkspacesilent 1, beeper
hyprctl dispatch movetoworkspacesilent 1, beeper