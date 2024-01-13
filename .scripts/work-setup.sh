#!/bin/zsh

#echo "`date` work-setup" >> $LOG_PATH
hyprctl dispatch workspace 4
hyprctl dispatch -- exec $SCRIPTS_PATH/mailspring-start.sh
hyprctl dispatch -- exec beeper
hyprctl dispatch -- exec zoom
hyprctl dispatch -- exec slack
hyprctl dispatch -- exec vivaldi-snapshot
hyprctl dispatch -- exec code
hyprctl dispatch -- exec $SCRIPTS_PATH/mailspring-start.sh


