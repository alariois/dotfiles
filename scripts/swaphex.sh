#!/usr/bin/env bash

swaphex() {
  INPUT="$1"
  NO_WHITESPACE="$(printf "$1" | sed 's/\s*//g')"
  PREFIX="$(printf "$NO_WHITESPACE" | grep -o '^.*[xX]')"
  SUFFIX="$(printf "$NO_WHITESPACE" | grep -o '[^0-9a-fA-F]$')"
# HEX="$(printf "$1" | sed "s/^$PREFIX//" | sed "s/$SUFFIX//")"
  HEX="$(printf "$NO_WHITESPACE" | sed "s/^$PREFIX//" | sed "s/$SUFFIX$//")"

  # Check if HEX has an odd number of characters
  if [ $(( ${#HEX} % 2 )) -ne 0 ]; then
      # If odd, pad with a leading 0
      HEX="0$HEX"
  fi

  SWAPPED="$(printf "$HEX" | sed 's/../&\n/g' | tac | tr -d '\n')";
  echo "$PREFIX$SWAPPED$SUFFIX"
}

export -f swaphex;
