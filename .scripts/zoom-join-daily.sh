#!/bin/zsh

pass=$(secret-tool lookup service zoom)
setsid xdg-open "zoommtg://zoom.us/join?action=join&video=on&confno=75993015411&pwd=$pass" &>/dev/null
