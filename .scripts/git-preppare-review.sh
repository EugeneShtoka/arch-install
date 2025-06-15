#!/bin/zsh

feature_branch=$(git branch --show-current)
echo "Feature branch: $feature_branch"

review_dir="$HOME/toReview"

# Re-create the review directory
echo "Cleaning and creating directory: $review_dir"
rm -rf "$review_dir"
mkdir -p "$review_dir"

echo "Copying changed files to $review_dir..."

# Get the list of changed files and pipe it to the loop
git diff --name-only "main...$feature_branch" | while read -r filepath; do
  # Check if the file actually exists before trying to copy
  if [ -f "$filepath" ]; then
    # Construct the destination filename
    dest_filename="$(basename "$filepath").orig"
    echo "  -> Copying $filepath to $review_dir/$dest_filename"
    
    # Use $HOME instead of ~ for reliable path expansion
    cp "$filepath" "$review_dir/$dest_filename"
  else
    echo "  -> Skipping $filepath (it may have been deleted)"
  fi
done

echo "Copy complete."

# If 'gsp' is an alias, this might not work. If it's a script/function, it's fine.
# gsp 

echo "Script finished on branch: $(git branch --show-current)"