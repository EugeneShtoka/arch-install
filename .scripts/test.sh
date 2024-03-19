#!/bin/zsh

tags="test rest best"
tags=${tags// /\\n   - }
filepath="Obsidian/Resources/Professional/Vertical Scaling.md"
if grep -q '^\-\-\-' "$filepath"; then
  sed -i "0,/^\-\-\-/s/$/\ntags:\n  -$tags/" "$filepath" 
else
  # Tags line doesn't exist, add it to the beginning
  echo -e "---\ntags:\n  $tags\n---\n$(cat "$filepath")" > "$filepath"
fi