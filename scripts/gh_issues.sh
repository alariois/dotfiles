#!/bin/bash

# Function to fetch and display issues
gh_issues_summary() {
# Check if `gh` and `jq` are installed
    if ! command -v gh &>/dev/null; then
        echo "Error: 'gh' CLI is not installed. Install it from https://cli.github.com/"
        return 1
    fi

    if ! command -v jq &>/dev/null; then
        echo "Error: 'jq' is not installed. Install it from https://stedolan.github.io/jq/"
        return 1
    fi

    # Fetch all issues (open and closed)
    echo "Fetching issues from the repository..."
    issues=$(gh issue list --state all --json number,title,state,body,comments --jq '.[]')

    # Prepare the CSV header
    csv_output="Issue Number,Title,State,Description,Comments\n"

    # Process each issue
    while IFS= read -r issue; do
        number=$(echo "$issue" | jq -r '.number')
        title=$(echo "$issue" | jq -r '.title' | tr ',' ' ' | tr '\n' ' ') # Remove commas and format for CSV
        state=$(echo "$issue" | jq -r '.state')
        description=$(echo "$issue" | jq -r '.body' | tr ',' ' ' | cut -c 1-100 | tr '\n' ' ') # Truncate for CSV
        comments=$(echo "$issue" | jq -r '.comments | map(.author.login + ": " + .body) | join(" | ")' | tr ',' ' ' | cut -c 1-100)

        # Add the issue data to the CSV output
        csv_output+="$number,\"$title\",$state,\"$description\",\"$comments\"\n"
    done <<<"$issues"

    # Print or save the CSV output
    if [ "$1" = "--save" ] && [ -n "$2" ]; then
        echo -e "$csv_output" > "$2"
        echo "CSV saved to $2"
    else
        echo -e "$csv_output"
    fi
  }

# Export the function
export -f gh_issues_summary

