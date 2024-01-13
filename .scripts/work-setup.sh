#!/bin/bash

#echo "`date` work-setup" >> $LOG_PATH
apps=(
    {"app": "$SCRIPTS_PATH/mailspring-start.sh", "className": "mailspring", "workspace": "1"}
    {"app": "beeper", "className": "beeper", "workspace": "1"}
    {"app": "zoom", "className": "zoom", "workspace": "2"}
    {"app": "slack", "className": "slack", "workspace": "2"}
    {"app": "vivaldi-snapshot", "className": "vivaldi-snapshot", "workspace": "4"}
    {"app": "code", "className": "Code", "workspace": "4"}
)

for tuple ({app} {className} {workspace}) in $apps; do
    echo "App: $app"
    echo "Class: $className"
    echo "Workspace: $workspace"

    hyprctl dispatch -- exec $app
    hyprctl dispatch movetoworkspacesilent "$workspace,address:$(hyprctl clients -j | jq -r '.[] | select(.class == "className") | .address')"
done