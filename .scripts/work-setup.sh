#!/bin/zsh

#echo "`date` work-setup" >> $LOG_PATH
hyprctl dispatch workspace 3
hyprctl dispatch -- exec $SCRIPTS_PATH/mailspring-start.sh
hyprctl dispatch -- exec beeper
hyprctl dispatch -- exec zoom
hyprctl dispatch -- exec slack
hyprctl dispatch -- exec vivaldi-snapshot
hyprctl dispatch -- exec code
sleep 5

hyprctl dispatch movetoworkspacesilent "1,address:$(hyprctl clients -j | jq -r '.[] | select(.class == "Mailspring") | .address')"
hyprctl dispatch movetoworkspacesilent "1,address:$(hyprctl clients -j | jq -r '.[] | select(.class == "Beeper") | .address')"
hyprctl dispatch movetoworkspacesilent "2,address:$(hyprctl clients -j | jq -r '.[] | select(.class == "zoom") | .address')"
hyprctl dispatch movetoworkspacesilent "2,address:$(hyprctl clients -j | jq -r '.[] | select(.class == "Slack") | .address')"
hyprctl dispatch movetoworkspacesilent "4,address:$(hyprctl clients -j | jq -r '.[] | select(.class == "Vivaldi-snapshot") | .address')"
hyprctl dispatch movetoworkspacesilent "4,address:$(hyprctl clients -j | jq -r '.[] | select(.class == "Code") | .address')"
hyprctl dispatch workspace 4



