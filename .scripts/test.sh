#!/bin/zsh

tags="test rest best"
filepath="Obsidian/Resources/Vertical Scaling.md"

tags=${tags// /\\n  - }
# Add the tags (prepend existing content as needed)
if grep -q '^tags:' "$filepath"; then
  # Tags line exists, insert our new tags before it
  sed -i "/^tags:/s/$/\n  - $tags/" "$filepath" 
else
  if grep -q '^---' "$filepath"; then
    sed -i "0,/^\-\-\-/s/$/\ntags:\n  - $tags/" "$filepath" 
  else
    # Tags line doesn't exist, add it to the beginning
    echo -e "---\ntags:\n  - $tags\n---\n$(cat "$filepath")" > "$filepath"
  fi
fi