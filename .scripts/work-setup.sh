#!/bin/zsh

#echo "`date` work-setup" >> $LOG_PATH
hyprctl dispatch workspace 4
hyprctl dispatch -- exec $SCRIPTS_PATH/mailspring-start.sh
hyprctl dispatch -- exec $SCRIPTS_PATH/obsidian-start.sh
hyprctl dispatch -- exec beeper
hyprctl dispatch -- exec vivaldi-snapshot
hyprctl dispatch -- exec code
hyprctl dispatch -- exec zoom
sleep 5
hyprctl dispatch -- exec slack

#hyprctl dispatch movetoworkspacesilent "3,address:$(hyprctl clients -j | jq -r '.[] | select(.class == "zoom") | .address')"
#hyprctl dispatch movetoworkspacesilent "2,address:$(hyprctl clients -j | jq -r '.[] | select(.class == "zoom") | .address')"