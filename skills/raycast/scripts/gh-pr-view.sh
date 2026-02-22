#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title View Current PR
# @raycast.mode fullOutput
# @raycast.packageName Git
# @raycast.icon 🔀
# @raycast.description View PR for current branch (auto-detects enterprise GitHub)

# Check if in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Not in a git repository"
  exit 1
fi

# Determine GitHub host from remote URL
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

# Auto-detect enterprise GitHub (any non-github.com host)
if [[ "$REMOTE_URL" =~ @([^:]+): ]] || [[ "$REMOTE_URL" =~ https?://([^/]+)/ ]]; then
  REMOTE_HOST="${BASH_REMATCH[1]}"
  if [[ "$REMOTE_HOST" != "github.com" ]]; then
    export GH_HOST="$REMOTE_HOST"
    echo "Using enterprise GitHub: $GH_HOST"
  else
    echo "Using public GitHub"
  fi
fi

echo ""
gh pr view --web 2>/dev/null || gh pr view
