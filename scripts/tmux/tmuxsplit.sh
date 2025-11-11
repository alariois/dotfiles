#!/usr/bin/env bash

tmuxsplit() {
  local FILES_GLOB="$1"
  local SPLIT_TYPE="-v"
  local LAYOUT="even-vertical"
  shift

  # Parse optional layout flag
  if [[ "$1" == "-v" || "$1" == "-h" || "$1" == "-t" ]]; then
    case "$1" in
      -v)
        SPLIT_TYPE="-v"
        LAYOUT="even-vertical"
        ;;
      -h)
        SPLIT_TYPE="-h"
        LAYOUT="even-horizontal"
        ;;
      -t)
        SPLIT_TYPE="-v"
        LAYOUT="tiled"
        ;;
    esac
    shift
  fi

  # Check for the command
  if [[ "$#" -lt 1 ]]; then
    echo "Usage: tmuxsplit '<glob>' [-v|-h|-t] -- command with {}"
    return 1
  fi

  local CMD=("$@")

  # Expand the files from glob
  local FILES=($(eval echo "$FILES_GLOB"))
  if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No files matched glob: $FILES_GLOB"
    return 1
  fi

  local FIRST_CMD="$(printf "%q " "${CMD[@]}" | sed "s/{}/${FILES[0]}/")"
  local REMAINING_FILES=("${FILES[@]:1}")

  if [[ -n "$TMUX" ]]; then
    # Inside tmux: create a new window in current session
    tmux new-window -n tmuxsplit "$FIRST_CMD"
  else
    # Not inside tmux: create a new session
    tmux new-session -d -s tmuxsplit "$FIRST_CMD"
  fi

  # Run remaining commands in split panes
  for f in "${REMAINING_FILES[@]}"; do
    tmux split-window "$SPLIT_TYPE" "$(printf "%q " "${CMD[@]}" | sed "s/{}/$f/")"
  done

  # Apply layout
  tmux select-layout "$LAYOUT"

  # Attach if not already inside tmux
  if [[ -z "$TMUX" ]]; then
    tmux attach-session -t tmuxsplit
  fi
}

export -f tmuxsplit
