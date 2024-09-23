#!/usr/bin/env bash

wgettail() {
    # Check if URL is provided
    if [ -z "$1" ]; then
        echo "Error: No URL provided."
        echo "Usage: wgettail <url> [--from-start]"
        return 1
    fi

    url=$1
    current_size=0
    show_from_start=false

    # Check if the second argument is "--from-start"
    if [ "$2" == "--from-start" ]; then
        show_from_start=true
    fi

    # Get the current file size (Content-Length) from the URL
    headers=$(curl -sI "$url")
    file_size=$(echo "$headers" | grep -i Content-Length | awk '{print $2}' | tr -d '\r')

    if [ -z "$file_size" ]; then
        echo "Error: Unable to retrieve file size. Check the URL."
        return 1
    fi

    # If starting from the end, set current_size to file_size
    if [ "$show_from_start" = false ]; then
        current_size=$file_size
    fi

    echo "Tailing $url (starting from ${current_size})..."

    # Main loop to tail the file
    while true; do
        headers=$(curl -sI "$url")
        new_size=$(echo "$headers" | grep -i Content-Length | awk '{print $2}' | tr -d '\r')

        if (( new_size > current_size )); then
            # Download only the new data using the Range header
            curl -s -r $current_size-$((new_size - 1)) "$url"
            current_size=$new_size
        fi

        # Wait for 5 seconds before the next check
        sleep 5
    done
}

export -f wgettail;
