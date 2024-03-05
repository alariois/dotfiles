#!/bin/bash


# THIS IS PAINFULLY SLOW! Rewrite in C?

# -s (select) fields to compare with cut and print color (-c)
# remrep  -s '-d: -f2' -c


# Define the remrep function
remrep() {
    local prevLine=""
    local count=0
    local enable_color=false
    local cutOptions=()

    # Function to print with color
    print_color() {
        local enable_color=$1; shift
        if $enable_color; then
            echo -n "$(tput setaf 2)$*$(tput sgr0)" # Apply color and reset
        else
            echo -n "$*"
        fi
    }


    # Process arguments
    while getopts ":cs:" opt; do
      case ${opt} in
        c )
          enable_color=true
          ;;
        s )
          # Split the cut options and store them in an array
          IFS=' ' read -r -a cutOptions <<< "$OPTARG"
          ;;
        \? )
          echo "Usage: remrep [-c] [-s 'cut_options']"
          return 1
          ;;
      esac
    done

    # Reset OPTIND to ensure getopts works for subsequent calls
    OPTIND=1

    # Function to extract the relevant part of the line using cut options
    extract_part() {
        if [ ${#cutOptions[@]} -ne 0 ]; then
            echo "$1" | cut "${cutOptions[@]}"
        else
            echo "$1"
        fi
    }

    # Read from stdin
    while IFS= read -r line; do
        local linePart=$(extract_part "$line")

        if [[ "$linePart" == "$prevLine" ]]; then
            ((count++))
            echo -en "\r\033[K$line $(print_color $enable_color "[repeated $count times]")"
        else
            if [[ -n $prevLine ]]; then
                echo
            fi
            count=1
            prevLine="$linePart"
            echo -n "$line"
            printf "\n"
        fi
    done

    if [[ $count -gt 1 ]]; then
        echo
    fi
}

# Export the remrep function
export -f remrep
