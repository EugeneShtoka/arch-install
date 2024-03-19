#!/bin/bash

# Check for a provided directory
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

source_dir="$1"
echo $source_dir

# Function to process a single Markdown file
process_md_file() {
  local filepath="$1"
  local filename=$(basename "$filepath")

  echo $source_dir, filepath: $filepath, filename: $filename
  # Build a list of tags from the directory structure
  local tags=""
  local dirpath=$(dirname "$filepath")
  while [[ "$dirpath" != "$source_dir" ]]; do
    echo dirpath: $dirpath
    tags="#$(basename "$dirpath") $tags" 
    dirpath=$(dirname "$dirpath") 
  done

#   # Add the tags (prepend existing content as needed)
#   if grep -q '^#tags:' "$filepath"; then
#     # Tags line exists, insert our new tags before it
#     sed -i "/^#tags:/i $tags" "$filepath" 
#   else
#     # Tags line doesn't exist, add it to the beginning
#     echo -e "$tags\n$(cat "$filepath")" > "$filepath"
#   fi
    echo filepath: $filepath, filename: $filename, tags: $tags
}

export -f process_md_file

# Recursively find and process Markdown files
find "$source_dir" -type f -name "*.md" -exec bash -c 'echo AAA $0 $sourceDir &&process_md_file "$0"' {} \; 