#!/usr/bin/env bash

swaphex() {
  # Determine input source: clipboard (-c or --clipboard), stdin (pipe), or direct argument
  if [[ "$1" == "-c" || "$1" == "--clipboard" ]]; then
    INPUT="$(xclip -se c -o)"  # Read input from clipboard
  elif [ -p /dev/stdin ]; then
    INPUT="$(cat -)"           # Read input from pipe
  else
    INPUT="$1"                 # Use provided argument as input
  fi

  # Remove whitespace from the input
  NO_WHITESPACE="$(echo "$INPUT" | sed 's/\s*//g')"

  # Get prefix (everything up to and including 0x or 0X)
  PREFIX="$(echo "$NO_WHITESPACE" | grep -o '^.*0[xX]')"
  PREFIX_LEN=${#PREFIX}

  # Get the rest of the string after PREFIX
  AFTER_PREFIX="${NO_WHITESPACE:PREFIX_LEN}"

  # Get suffix (anything that comes after the hex characters)
  SUFFIX="$(echo "$AFTER_PREFIX" | grep -o '[^0-9a-fA-F].*')"

  # Extract the hex part by removing PREFIX and SUFFIX
  HEX="$(echo "$NO_WHITESPACE" | sed "s/^$PREFIX//" | sed "s/$SUFFIX$//")"

  # Check if HEX has an odd number of characters, pad with 0 if needed
  if [ $(( ${#HEX} % 2 )) -ne 0 ]; then
      HEX="0$HEX"
  fi

  # Swap the endianness of HEX
  SWAPPED="$(echo "$HEX" | sed 's/../&\n/g' | tac | tr -d '\n')"

  # Final result
  RESULT="$PREFIX$SWAPPED$SUFFIX"
  echo "$RESULT"

  # If -c or --clipboard flag is provided, copy the result back to clipboard
  if [[ "$1" == "-c" || "$1" == "--clipboard" ]]; then
    printf "%s" "$RESULT" | xclip -se c
  fi
}

export -f swaphex
