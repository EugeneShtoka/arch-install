#!/bin/zsh

# Construct the output filename and path
current_date=$(date +%Y-%m-%d_%H-%M-%S)
output_path="$HOME/Screenshots/${current_date}.png"

# Take the screenshot using maim
if [[ $1 == "window" ]]; then
  maim -u -i $(xdotool getactivewindow) "$output_path"
else
  maim -u "$output_path"
fi

# Copy the filename to the clipboard
echo "$output_filename" | xclip -selection clipboard

# Notify the user if successful
if [[ $? -eq 0 ]]; then
  echo "Screenshot saved as $output_path"
fi
