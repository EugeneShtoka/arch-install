#!/bin/bash

#echo "`date` work-setup" >> $LOG_PATH
hyprctl dispatch -- exec '[title;workspace 1 silent]' $SCRIPTS_PATH/mailspring-start.sh
hyprctl dispatch -- exec '[title;workspace 1 silent]' beeper

hyprctl dispatch -- exec '[title;workspace 2 silent]' zoom
hyprctl dispatch -- exec '[title;workspace 2 silent]' slack

#hyprctl dispatch exec '[workspace 4 silent]' vivaldi
hyprctl dispatch -- exec '[title;workspace 4 silent]' code

sleep 5

hyprctl dispatch movetoworkspacesilent 1, Beeper
hyprctl dispatch movetoworkspacesilent 1, mailspring

hyprctl dispatch movetoworkspacesilent 2, zoom
hyprctl dispatch movetoworkspacesilent 2, Slack

hyprctl dispatch movetoworkspacesilent 4, Google-chrome
hyprctl dispatch movetoworkspacesilent 4, Code