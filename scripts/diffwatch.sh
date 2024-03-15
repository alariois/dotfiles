# diffwatch: Monitors the output of a given command and shows differences from its initial run over time.
# Usage: diffwatch [watch options] 'command'
# Example: diffwatch -n 1 'lsusb | sort -u'
# This example uses 'watch' with a 1-second interval to monitor changes in the sorted USB device list.
# More complex example:
# diffwatch -n .1 -- 'udevadm info /dev/ttyACM* | grep '\''ID_MODEL'\'''

diffwatch() {
    # Create a temporary file
    local F=$(mktemp)

    # Ensure the temporary file is deleted when the script exits or is interrupted
    trap "rm -f '$F'" EXIT

    # The last argument is the command to be executed, stored separately
    local CMD="${@: -1}"

    # All arguments except the last one are assumed to be for `watch`
    local WATCH_ARGS=("${@:1:$(($#-1))}")

    # Execute the command and store its output in the temporary file
    eval "$CMD" > "$F"

    # Store the initial state of the command output in a variable
    local R=$(cat "$F")

    # Use watch with the provided arguments to continuously compare the current output with the initial state
    watch "${WATCH_ARGS[@]}" "bash -c 'diff <(echo \"$R\") <(eval \"$CMD\")'"
}

export -f diffwatch
