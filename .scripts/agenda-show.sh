#!/bin/zsh

source $SCRIPTS_PATH/meetings.sh

daysToShow=$1
notify-send "Agenda" "<span font='15px'>$(agenda $daysToShow)</span>"

