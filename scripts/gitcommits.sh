#!/usr/bin/env bash

gitcommits() {
  USER="${1:-alariois}"
  ORG="${2:-superhandsrepo}"

  # If SINCE (arg 3) is provided, use it; otherwise default to 1 month ago
  if [ -n "${3:-}" ]; then
    SINCE="$3"
  else
    SINCE="$(date -d '1 month ago' +%Y-%m-%d)"
  fi

  TOKEN="$(pass ghread)"

  echo "user:  |$USER|"
  echo "org:   |$ORG|"
  echo "since: |$SINCE|"

  curl -H "Accept: application/vnd.github.cloak-preview+json" \
    -H "Authorization: Bearer $TOKEN" \
    "https://api.github.com/search/commits?q=author:$USER+org:$ORG+committer-date:>=$SINCE&per_page=100&page=1" \
    | jq -r '.items[]
  | [.commit.author.date,
  .repository.name,
  (.commit.message | split("\n")[0])]
  | @tsv' \
    | column -t -s $'\t'
  }

export -f gitcommits
