#!/bin/zsh

awk "NR==$1 {print \$$2}" | xclip -selection clipboard
