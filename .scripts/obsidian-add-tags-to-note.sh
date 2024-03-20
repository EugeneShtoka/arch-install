#!/bin/zsh

filepath="$1"
tags="$2"

first_line=$(head -n 1 $filepath)
echo filepath: $filepath, tags: $tags, first_line: $first_line
tags="\n  - ${(L)tags// /\\n  - }"
echo filepath: $filepath, tags: $tags
# Add the tags (prepend existing content as needed)
if grep -q '^tags:' "$filepath"; then
  # Tags line exists, insert our new tags before it
  echo "case 1"
  sed -i "0,/^tags:/s/$/$tags/" "$filepath" 
else
  if grep -q '^---' "$filepath"; then
    echo "case 2"
    sed -i "0,/^---/s/$/\ntags:$tags/" "$filepath" 
  else
    echo "case 3"
    # Tags line doesn't exist, add it to the beginning
    echo -e "---\ntags:$tags\n---\n$(cat "$filepath")" > "$filepath"
  fi
fi