#!/bin/zsh

folder=~/.zshfn

for file in $(ls ~/.zshfn); do
  unset -f "$file"
done
