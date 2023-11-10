#!/bin/bash

sync_project() {
    local extra_excludes=()
    local dry_run=""

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --exclude=*)
                extra_excludes+=("${1#*=}")
                ;;
            --dry-run)
                dry_run="--dry-run"
                ;;
            -n)
                dry_run="-n"
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 [options] source_directory destination_directory"
        echo "Options:"
        echo "  --exclude=PATTERN   Exclude files matching PATTERN"
        echo "  --dry-run           Perform a trial run with no changes made"
        return 1
    fi

    SOURCE_DIR=$1
    DESTINATION_DIR=$2

    TEMP_IGNORE=$(mktemp)
    git -C "$SOURCE_DIR" ls-files --ignored --exclude-standard --others > "$TEMP_IGNORE"
    cat "$SOURCE_DIR/.gitignore" >> "$TEMP_IGNORE"

    # Check if there are any extra exclude patterns and print them
    if [ ${#extra_excludes[@]} -gt 0 ]; then
        echo "Extra exclude patterns:"
        echo "-----------------"
        for exclude in "${extra_excludes[@]}"; do
            echo "$exclude"
            printf "\n$exclude" >> "$TEMP_IGNORE"
        done
        echo "-----------------"
    fi

    awk '!seen[$0]++' "$TEMP_IGNORE" > "${TEMP_IGNORE}_filtered"
    mv "${TEMP_IGNORE}_filtered" "$TEMP_IGNORE"

    # echo 'ignore file:'
    # cat "$TEMP_IGNORE"
    echo "Running rsync command:"
    echo "rsync -va --info=progress2 ${dry_run} --exclude-from='$TEMP_IGNORE' '$SOURCE_DIR' '$DESTINATION_DIR'"

    time rsync -va --info=progress2 ${dry_run} --exclude-from="$TEMP_IGNORE" "$SOURCE_DIR" "$DESTINATION_DIR"
    rm "$TEMP_IGNORE"
}
