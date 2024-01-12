#!/bin/bash

#echo "`date` work-setup" >> $LOG_PATH
hyprctl dispatch -- exec '[title;workspace 1 silent]' $SCRIPTS_PATH/mailspring-start.sh
hyprctl dispatch -- exec '[title;workspace 1 silent]' beeper

hyprctl dispatch -- exec '[title;workspace 2 silent]' zoom
hyprctl dispatch -- exec '[title;workspace 2 silent]' slack

hyprctl dispatch -- exec '[tite;workspace 4 silent]' vivaldi-snapshot
hyprctl dispatch -- exec '[title;workspace 4 silent]' code

sleep 15

hyprctl dispatch movetoworkspacesilent "2,address:0x5610b819b6e0"
hyprctl dispatch movetoworkspacesilent "4,address:0x5610b8174a40"
