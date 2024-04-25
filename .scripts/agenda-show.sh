#!/bin/zsh

source $SCRIPTS_PATH/meetings.sh

daysToShow=$1
bindsym $mod+a notify-send "Agenda" "<span font='15px'>$(agenda $1)</span>"

