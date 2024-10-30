#!/bin/bash

gitroot() {
# Get the absolute path of the current directory
  target_dir="$(pwd)"
  current_path="/"

# Split the target directory path into components
  IFS='/' read -ra path_components <<< "$target_dir"

# Drill down through each directory component from root
  for component in "${path_components[@]}"; do
      if [ -n "$component" ]; then
          current_path="$current_path$component/"
      fi

      # Check if the current path is a bare Git repository
      if git --git-dir="$current_path" rev-parse --is-bare-repository &>/dev/null; then
          echo "$current_path"
          return 0
      fi
  done

  echo "No bare Git repository found."
  return 1
}

export -f gitroot
