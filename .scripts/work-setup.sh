#!/bin/bash

#echo "`date` launch-silently $1 $2" >> $LOG_PATHa
hyprctl dispatch -- exec [workspace $1 silent] $2