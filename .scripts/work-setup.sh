#!/bin/bash

#echo "`date` work-setup" >> $LOG_PATH
hyprctl dispatch exec '[workspace 1 silent]' beeper
$SCRIPTS_PATH/mailspring-start.sh

hyprctl dispatch exec '[workspace 2 silent]' zoom
hyprctl dispatch exec '[workspace 2 silent]' slack

hyprctl dispatch exec '[workspace 4 silent]' google-chrome-stable
hyprctl dispatch exec '[workspace 4 silent]' code

sleep 2

hyprctl dispatch movetoworkspacesilent 1, Beeper
hyprctl dispatch movetoworkspacesilent 1, mailspring

hyprctl dispatch movetoworkspacesilent 2, zoom
hyprctl dispatch movetoworkspacesilent 2, Slack

hyprctl dispatch movetoworkspacesilent 4, google-chrome-stable
hyprctl dispatch movetoworkspacesilent 4, Code