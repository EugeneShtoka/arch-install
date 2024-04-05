#!/bin/zsh

# Set default mode to full screen
mode="fullscreen"

# Check for "window" argument
if [[ $1 == "window" ]]; then
  mode="window"
fi

# Get the current date and time in a suitable format
current_date=$(date +%Y-%m-%d_%H-%M-%S)

# Construct the output filename and path
output_filename="screenshot_${current_date}.png"
output_path="$HOME/Downloads/$output_filename"

# Take the screenshot using maim
if [[ $mode == "window" ]]; then
  maim -u -i $(xdotool getactivewindow) "$output_path"
else
  maim -u  "$output_path" 
fi

# Copy the filename to the clipboard
echo "$output_filename" | xclip -selection clipboard

# Notify the user if successful
if [[ $? -eq 0 ]]; then
  echo "Screenshot saved as $output_path"
fi