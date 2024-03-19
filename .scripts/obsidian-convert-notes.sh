#!/bin/bash

# Check for a provided directory
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

export source_dir="$1"

# Function to process a single Markdown file
process_md_file() {
  local filepath="$1"
  local filename=$(basename "$filepath")

  # Build a list of tags from the directory structure
  local tags=""
  local dirpath=$(dirname "$filepath")
  while [[ "$dirpath" != "$source_dir" ]]; do
    echo dirpath: $dirpath
    tags="$(basename "$dirpath") $tags" 
    dirpath=$(dirname "$dirpath") 
  done

  tags=${tags,,}
  tags=${tags// /\\n  - }
  # Add the tags (prepend existing content as needed)
  if grep -q '^tags:' "$filepath"; then
    # Tags line exists, insert our new tags before it
    sed -i "0,/^tags:/s/$/\n  - $tags/" "$filepath" 
  else
    if grep -q '^---' "$filepath"; then
      sed -i "0,/^\-\-\-/s/$/\ntags:\n  - $tags/" "$filepath" 
    else
      # Tags line doesn't exist, add it to the beginning
      echo -e "---\ntags:\n  - $tags\n---\n$(cat "$filepath")" > "$filepath"
    fi
  fi
  #mv "$filepath" "$source_dir/"
}

export -f process_md_file

# Recursively find and process Markdown files
find "$source_dir" -type f -name "*.md" -exec bash -c 'process_md_file "$0"' {} \; 