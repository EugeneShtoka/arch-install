#!/bin/zsh

ps aux | grep -v grep | grep -i -e VSZ -e $1 | grep -b 1 -i $1