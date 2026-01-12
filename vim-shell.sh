#!/bin/bash
# next test comment

# Log the received command
# echo "Received command: $@" >> ~/vim-shell-debug.log

# Source the aliases file
if [ -f ~/.aliases ]; then
    # echo "Sourcing ~/.aliases" >> ~/vim-shell-debug.log
    source ~/.aliases
fi

if [ -f ~/scripts/histogram.sh ]; then
    # echo "Sourcing ~/.aliases" >> ~/vim-shell-debug.log
    source ~/scripts/histogram.sh
fi

# Execute the command
if [ "$1" = "-c" ]; then
    shift  # Remove the first argument ("-c")
    eval "$@" || echo "Command failed: $@" >&2
else
    "$@" || echo "Command failed: $@" >&2
fi
