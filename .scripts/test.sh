#!/bin/zsh

filepath="Obsidian/Resources/Professional/Architecture/Terms/Vertical Scaling.md"
if grep -q '^\-\-\-' "$filepath"; then
  sed -i "0,/^\-\-\-/s/$/\ntags: test rest best/" "$filepath" 
else
  # Tags line doesn't exist, add it to the beginning
  echo -e "---\ntags: $tags\n---\n$(cat "$filepath")" > "$filepath"
fi