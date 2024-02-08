#!/bin/bash

histogram() {
    # Default values
    local max_length=0  # Use 0 as a flag for dynamic max_length
    local delimiter="*"
    local sort_numeric=false
    local separator=$'\t'  # Assigning tab as the separator

    # Process command-line options
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -m|--max) max_length="$2"; shift ;;
            -d|--delimiter) delimiter="$2"; shift ;;
            -n) sort_numeric=true ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
        shift
    done

    # Main pipeline with normalization, ignoring empty lines, and final column formatting
    grep -v '^$' | sort | uniq -c | awk -v max="$max_length" -v delim="$delimiter" -v sep="$separator" '
    BEGIN {max_count=0}
    {count[$2]=$1; if ($1>max_count) max_count=$1}
    END {
        for (value in count) {
            norm_count = (max==0) ? count[value] : int((count[value]/max_count)*max);
            printf "%s%s%d%s", value, sep, count[value], sep;
            for (i=0; i<norm_count; i++) printf delim;
            print "";
        }
    }' | { if [ "$sort_numeric" = true ] ; then sort -n; else sort; fi } | column -t -s "$separator"
}

export -f histogram
