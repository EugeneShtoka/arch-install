#!/bin/zsh

#echo "`date` work-setup" >> $LOG_PATH
hyprctl dispatch workspace 
hyprctl dispatch -- exec $SCRIPTS_PATH/mailspring-start.sh
hyprctl dispatch -- exec $SCRIPTS_PATH/obsidian-start.sh
hyprctl dispatch -- exec vivaldi-snapshot
hyprctl dispatch -- exec beeper
hyprctl dispatch -- exec code
hyprctl dispatch -- exec zoom
sleep 3
hyprctl dispatch -- exec slack
