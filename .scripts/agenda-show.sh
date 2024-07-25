#!/bin/zsh

source $SCRIPTS_PATH/meetings.sh

daysToShow=$1
title=Agenda
if [[ $daysToShow -eq 1 ]]; then
    title=Daily
elif [[ $daysToShow -eq 7 ]]; then
    title=Weekly
fi

dunstify "$title" "<span font='15px'>$(agenda $daysToShow)</span>" --icon=" " -r 101017

