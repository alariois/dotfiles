#!/bin/bash

jsonstr() {
    # Check if there is input coming from stdin
    if [ ! -t 0 ]; then
        # There is input from stdin, so just pass it to the Node.js script
        node ~/scripts/jsonstr/jsonstr.js
    else
        # No input from stdin
        if [ "$#" -gt 0 ]; then
            # If there are arguments, concatenate them and pass to the Node.js script
            echo "$*" | node ~/scripts/jsonstr/jsonstr.js
        else
            # No arguments, so use xclip to get clipboard content and pass to the Node.js script
            xclip -o -selection clipboard | node ~/scripts/jsonstr/jsonstr.js
        fi
    fi
}

jqstr() {
    # Run jsonstr and then pipe its output to jq with any additional arguments passed to jqstr
    jsonstr | jq "$@"
}

fxstr() {
    # Run jsonstr and then pipe its output to fx with any additional arguments passed to fxstr
    jsonstr | fx "$@"
}

export -f jsonstr
export -f fxstr
export -f jqstr
