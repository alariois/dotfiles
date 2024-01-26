#!/bin/bash
# Source the aliases file
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Execute the command passed to the script
"$@"

