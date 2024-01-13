#!/bin/bash
hyprctl dispatch -- exec $1
sleep 3
hyprctl dispatch movetoworkspacesilent "$3,address:$(hyprctl clients -j | jq -r --arg class \"$2\" '.[] | select(.class == $class) | .address')"
