#!/bin/bash
# Check if the buffer index is provided
if [ -z "$1" ]; then
  echo "Buffer index is required."
  exit 1
fi

# Copy the buffer content to the clipboard
tmux show-buffer -b $1 | xclip -selection clipboard
