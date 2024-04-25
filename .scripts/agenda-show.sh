#!/bin/zsh

source $SCRIPTS_PATH/meetings.sh

bindsym $mod+a notify-send "Agenda" "<span font='15px'>$(agenda 7)</span>"

