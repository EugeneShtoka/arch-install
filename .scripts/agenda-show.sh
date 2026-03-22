#!/bin/zsh

source $SCRIPTS_PATH/meetings.sh
source $SCRIPTS_PATH/notify-lib.sh

daysToShow=$1
title=Agenda
if [[ $daysToShow -eq 1 ]]; then
    title=Daily
elif [[ $daysToShow -eq 7 ]]; then
    title=Weekly
fi

notify_send "$title" "<span font='15px'>$(agenda $daysToShow)</span>" --icon " " -r 101017

