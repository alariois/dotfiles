#!/usr/bin/env bash

swaphexline() {
  INPUT="$1"                 # Use provided argument as input

  # Get prefix (everything up to and including 0x or 0X)
  PREFIX="$(echo "$INPUT" | grep -o '^.*0[xX]')"
  PREFIX_LEN=${#PREFIX}

  # Get the rest of the string after PREFIX
  AFTER_PREFIX="${INPUT:PREFIX_LEN}"

  # Get suffix (anything that comes after the hex characters)
  SUFFIX="$(echo "$AFTER_PREFIX" | grep -o '[^0-9a-fA-F].*')"

  # Extract the hex part by removing PREFIX and SUFFIX
  HEX="$(echo "$INPUT" | sed "s/^$PREFIX//" | sed "s/$SUFFIX$//")"

  # echo "PREFIX: $PREFIX"
  # echo "SUFFIX: $SUFFIX"

  # Check if HEX has an odd number of characters, pad with 0 if needed
  if [ $(( ${#HEX} % 2 )) -ne 0 ]; then
      HEX="0$HEX"
  fi

  # Swap the endianness of HEX
  SWAPPED="$(echo "$HEX" | sed 's/../&\n/g' | tac | tr -d '\n')"

  # Final result for the current line
  RESULT="$PREFIX$SWAPPED$SUFFIX"
  echo "$RESULT"
}

swaphex() {
  # Determine input source: clipboard (-c or --clipboard), stdin (pipe), or direct argument
  if [[ "$1" == "-c" || "$1" == "--clipboard" ]]; then
    INPUT="$(xclip -se c -o)"  # Read input from clipboard
  elif [ -p /dev/stdin ]; then
    INPUT="$(cat -)"           # Read input from pipe
  else
    INPUT="$1"                 # Use provided argument as input
  fi

  # Initialize an empty variable to accumulate results
  RESULTS=""

  COUNT=0

  while IFS= read -r line; do
    # Process each line with swaphexline and accumulate results
    if [[ $COUNT -ne 0 ]]; then
      RESULTS+=$'\n'
    fi
    ((COUNT++))

    RESULTS+="$(swaphexline "$line")"
    # echo "LINE: $line"
  done <<< "$INPUT"

  # Print the accumulated results
  echo -e "$RESULTS"

  # If -c or --clipboard flag is provided, copy all results to clipboard
  if [[ "$1" == "-c" || "$1" == "--clipboard" ]]; then
    echo -e "$RESULTS" | xclip -se c
  fi
}

export -f swaphex

