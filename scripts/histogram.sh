#!/bin/bash

# This bash script generates a histogram from input text, where each unique line is represented along with its frequency.
# The histogram visualizes the frequency using a specified fill character. The script supports several options
# for customization, such as setting the maximum length for histogram bars, changing the fill character, sorting the output,
# and specifying a custom line separator.

# Usage:
#   - Pipe input text into the script: `echo -e "text\nmore text" | histogram`
#   - Options:
#       -m|--max-bar-length [number]: Set the maximum length of the histogram bars.
#       -f|--fill-character [character]: Change the character used for the histogram bars (default is '*').
#       -s|--sort-mode [mode]: Sort output by 'numeric', 'count', or 'alpha' (default).
#       -l|--line-separator [character]: Specify a custom line separator (default is tab).

# Examples:
#   1. Basic usage with piped input:
#      echo -e "apple\nbanana\napple" | histogram
#      # Output:
#      # apple    2 **
#      # banana   1 *
#
#   2. Using a custom fill character and sorting by count:
#      echo -e "apple\nbanana\napple" | histogram -f "#" -s count
#      # Output:
#      # apple    2 ##
#      # banana   1 #
#
#   3. Setting a maximum length for the histogram bars and custom line separator:
#      echo -e "apple\nbanana\napple" | histogram -m 1 -l " | "
#      # Output (normalized to max length of 1):
#      # apple | 2 | *
#      # banana | 1 | *

histogram() {
    local maxBarLength=0  # Use 0 as a flag for dynamic bar length
    local fillCharacter="*"
    local sortMode="alpha"  # Default to alphabetic sort
    local lineSeparator=$'\t'  # Default to tab as the separator

    # Process command-line options
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -m|--max-bar-length) maxBarLength="$2"; shift ;;
            -f|--fill-character) fillCharacter="$2"; shift ;;
            -s|--sort-mode) sortMode="$2"; shift ;;
            -l|--line-separator) lineSeparator="$2"; shift ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
        shift
    done

    # Main pipeline: trim, sort, count, and generate histogram
    grep -v '^$' | sed 's/^[ \t]*//;s/[ \t]*$//' | sort | uniq -c | awk -v max="$maxBarLength" -v fill="$fillCharacter" -v sep="$lineSeparator" '
    BEGIN {max_count=0}
    {
        line = substr($0, index($0, $2));  # Get the original line excluding the leading count
        count[line] = $1;
        if ($1 > max_count) max_count = $1;
    }
    END {
        for (line in count) {
            norm_count = (max == 0) ? count[line] : int((count[line] / max_count) * max);
            printf "%s%s%d%s", line, sep, count[line], sep;
            for (i = 0; i < norm_count; i++) printf fill;
            print "";
        }
    }' | {
        if [ "$sortMode" = "count" ] ; then
            sort -t $'\t' -k2,2n
        elif [ "$sortMode" = "numeric" ] ; then
            sort -n
        else
            sort
        fi
    } | column -t -s "$lineSeparator"
}

# If the script is executed directly, run the histogram function with all passed arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  histogram "$@"
fi
