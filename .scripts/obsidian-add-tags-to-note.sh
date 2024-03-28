#!/bin/zsh

filepath="$1"
tags="$2"

first_line=$(head -n 1 $filepath)
tags="\n  - ${(L)tags//|/\\n  - }"

# Add the tags (prepend existing content as needed)
if grep -q '^tags:' "$filepath"; then
  # Tags line exists, insert our new tags before it
  sed -i "0,/^tags:/s/$/$tags/" "$filepath" 
else
  if [[ $first_line == "---" ]]; then
    sed -i "0,/^---/s/$/\ntags:$tags/" "$filepath" 
  else
    # Tags line doesn't exist, add it to the beginning
    echo -e "---\ntags:$tags\n---\n$(cat "$filepath")" > "$filepath"
  fi
fi

