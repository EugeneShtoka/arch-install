#!/bin/zsh

pattern='Progress: ([0-9.]+)%, dl from [0-9]+ of [0-9]+ peers \(([^)]+)\)'
ls "$TORRENTS_DIR" | while read dir; do
    progress=$(cat $TORRENTS_DIR/"$dir"/progress.log | tr '\r' '\n' | grep Progress | tail -1)
    if [[ $progress =~ $pattern ]]; then  # Check if line matches the pattern
        progress=${match[1]}            # Extract progress percentage
        speed=${match[2]}              # Extract download speed

        echo "$dir $progress% ($speed)"
  fi
    # Perform actions here on each child directory (optional)
done