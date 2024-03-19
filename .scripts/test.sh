#!/bin/zsh

filepath="Obsidian/Resources/Professional/Architecture/Terms/Vertical Scaling.md"
if grep -q '^\-\-\-' "$filepath"; then
  sed -i "/^\-\-\-/s/$/\ntags: test rest best\n/" "$filepath" 
else
  # Tags line doesn't exist, add it to the beginning
  echo -e "---\ntags: $tags\n---\n$(cat "$filepath")" > "$filepath"
fi