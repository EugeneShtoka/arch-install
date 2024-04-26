#!/bin/zsh

source $SCRIPTS_PATH/meetings.sh

daysToShow=$1
title=Agena

notify-send "$title" "<span font='15px'>$(agenda $daysToShow)</span>"

