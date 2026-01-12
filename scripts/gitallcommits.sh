#!/usr/bin/env bash

gitallcommits() {
  local USER="alariois"
  local ORG="superhandsrepo"
  local SINCE=""
  local DO_FETCH=0

  # --- parse args ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --user|-u)
        USER="$2"; shift 2;;
      --org|-o)
        ORG="$2"; shift 2;;
      --since|-s)
        SINCE="$2"; shift 2;;
      --fetch)
        DO_FETCH=1; shift;;
      --help|-h)
        echo "Usage: gitallcommits [--user USER] [--org ORG] [--since YYYY-MM-DD] [--fetch]"
        echo "  --user / -u   Git author name/email to filter (default: ${USER})"
        echo "  --org  / -o   GitHub org (default: ${ORG})"
        echo "  --since / -s  Since date (default: 1 month ago)"
        echo "  --fetch       Fetch latest changes for already cloned repos"
        return 0;;
      *)
        echo "Unknown option: $1" >&2
        return 1;;
    esac
  done

  # default since: 1 month ago
  if [[ -z "$SINCE" ]]; then
    SINCE="$(date -d '1 month ago' +%Y-%m-%d)"
  fi

  echo "user:  |$USER|"
  echo "org:   |$ORG|"
  echo "since: |$SINCE|"
  echo "fetch: |$DO_FETCH|"

  # Where we keep local clones (bare, blobless)
  local BASE_DIR="/tmp/${ORG}-repos"
  mkdir -p "$BASE_DIR"
  cd "$BASE_DIR" || { echo "Cannot cd to $BASE_DIR"; return 1; }

  # Get all repo names in the org (via gh CLI)
  mapfile -t repos < <(gh repo list "$ORG" --json name --limit 1000 -q '.[].name')

  # Clone or (optionally) fetch each repo as BARE + BLOBLESS over SSH
  for repo in "${repos[@]}"; do
    local REPO_DIR="${BASE_DIR}/${repo}.git"

    if [[ -d "$REPO_DIR" ]]; then
      if [[ "$DO_FETCH" -eq 1 ]]; then
        echo "[$repo] fetching latest changes..."
        git --git-dir="$REPO_DIR" fetch --all --prune --quiet || {
          echo "[$repo] fetch failed"
        }
      else
        echo "[$repo] already cloned (skip fetch)"
      fi
    else
      echo "[$repo] cloning (ssh)..."
      git clone --bare --filter=blob:none \
        "git@github.com:${ORG}/${repo}.git" "$REPO_DIR" --quiet || {
        echo "[$repo] clone failed"
        continue
      }
    fi
  done

  # Temp file to collect all logs (we store SHA too for summary)
  local TMP
  TMP="$(mktemp)"

  {
    for repo in "${repos[@]}"; do
      local REPO_DIR="${BASE_DIR}/${repo}.git"
      [[ -d "$REPO_DIR" ]] || continue

      # All local + origin/* branches, but skip any *HEAD
      mapfile -t branches < <(
        git --git-dir="$REPO_DIR" for-each-ref \
          refs/heads refs/remotes/origin \
          --format='%(refname:short)' \
        | grep -v 'HEAD$' || true
      )

      for branch in "${branches[@]}"; do
        [[ "$branch" == *HEAD ]] && continue

        git --git-dir="$REPO_DIR" log "$branch" \
          --since="$SINCE" \
          --author="$USER" \
          --date=iso-local \
          --pretty=format:"%H%x09%ad%x09${repo}%x09${branch}%x09%s" \
          || true
        echo
      done
    done
  } | sed '/^$/d' > "$TMP"

  if [[ ! -s "$TMP" ]]; then
    echo "No commits found for '$USER' in '$ORG' since $SINCE"
    rm -f "$TMP"
    return 0
  fi

  # Pretty table output (drop SHA column)
  sort "$TMP" \
    | awk -F'\t' '{printf "%s\t%s\t%s\t%s\n", $2, $3, $4, $5}' \
    | column -t -s $'\t'

  # Summary: count unique SHAs (distinct commits)
  local COUNT
  COUNT=$(cut -f1 "$TMP" | sort -u | wc -l | tr -d ' ')

  echo
  echo "${USER} has made ${COUNT} commits since ${SINCE}"

  rm -f "$TMP"
}

export -f gitallcommits

