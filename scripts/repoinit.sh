#!/usr/bin/env bash

repoinit() {
  REPO_INIT_DIR="$HOME/projects/init"

  PROJECT="${1:?Project not provided}"

  "$REPO_INIT_DIR/$PROJECT/init.sh"
}

export -f repoinit
