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

  echo "$filepath"
  # Build a list of tags from the directory structure
  local tags=""
  local dirpath=$(dirname "$filepath")
  while [[ "$dirpath" != "$source_dir" ]]; do
    tag="$(basename "$dirpath")"
    if [[ -n "$tags" ]]; then
      tags="$tag|$tags"
    else
      tags="$tag"
    fi
    dirpath=$(dirname "$dirpath") 
  done

  if [[ -n "$tags" ]]; then
    $SCRIPTS_PATH/obsidian-add-tags-to-note.sh "$filepath" "$tags"
  fi
  #mv "$filepath" "$source_dir/"
}

export -f process_md_file

# Recursively find and process Markdown files
find "$source_dir" -type f -name "*.md" -exec bash -c 'process_md_file "$0"' {} \; 