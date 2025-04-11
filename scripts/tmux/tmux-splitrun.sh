#!/usr/bin/env bash

FILES_GLOB="$1"
SPLIT_TYPE="-v"
LAYOUT="even-vertical"
shift

# Parse optional layout flag
if [[ "$1" == "-v" || "$1" == "-h" ]]; then
  if [ "$1" == "-h" ]; then
    SPLIT_TYPE="-h"
    LAYOUT="even-horizontal"
  fi
  shift
elif [[ "$1" == "--tiled" ]]; then
  SPLIT_TYPE="-v"
  LAYOUT="tiled"
  shift
fi

# Get the command to run
CMD="$*"

# Get files from the glob
FILES=($(eval echo $FILES_GLOB))
FIRST="${FILES[0]}"

# Start a new tmux window and tail the first file
tmux new-window -n splitrun "$CMD" | sed "s/{}/$FIRST/g"

# Run the rest in split panes
for f in "${FILES[@]:1}"; do
  tmux split-window $SPLIT_TYPE "$(echo "$CMD" | sed "s/{}/$f/g")"
done

# Apply layout
tmux select-layout $LAYOUT

