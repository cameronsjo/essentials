#!/usr/bin/env bash
# Stop hook: Remind about uncommitted work before session ends
# Provides helpful reminders without blocking

set -euo pipefail

# Read the input JSON from stdin
INPUT=$(cat)

# Extract stop_hook_active field (if it exists) - prevent recursion
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Check if this is a development session by looking for write operations
HAS_WRITES=$(echo "$INPUT" | jq -r '.transcript // [] | map(select(.tool == "Write" or .tool == "Edit")) | length')
HAS_BASH=$(echo "$INPUT" | jq -r '.transcript // [] | map(select(.tool == "Bash")) | length')

# If this is just a read-only session, no reminder needed
if [[ "$HAS_WRITES" -eq 0 ]] && [[ "$HAS_BASH" -lt 3 ]]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Build reminder message
REMINDERS=()

# Check for uncommitted changes if in a git repo
if git rev-parse --is-inside-work-tree &>/dev/null; then
  # Get git status
  STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  MODIFIED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  if [[ "$STAGED" -gt 0 ]] || [[ "$MODIFIED" -gt 0 ]]; then
    TOTAL=$((STAGED + MODIFIED))
    REMINDERS+=("📝 $TOTAL file(s) with uncommitted changes")

    if [[ "$STAGED" -gt 0 ]]; then
      REMINDERS+=("   └─ $STAGED staged, ready to commit")
    fi
    if [[ "$MODIFIED" -gt 0 ]]; then
      REMINDERS+=("   └─ $MODIFIED modified, not staged")
    fi
  fi

  if [[ "$UNTRACKED" -gt 0 ]]; then
    REMINDERS+=("📄 $UNTRACKED untracked file(s)")
  fi

  # Check if on a feature branch with commits ahead
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  if [[ -n "$CURRENT_BRANCH" ]] && [[ "$CURRENT_BRANCH" != "main" ]] && [[ "$CURRENT_BRANCH" != "master" ]]; then
    # Check if there's an upstream to compare against
    if git rev-parse --abbrev-ref @{u} &>/dev/null; then
      AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
      if [[ "$AHEAD" -gt 0 ]]; then
        REMINDERS+=("🚀 Branch '$CURRENT_BRANCH' is $AHEAD commit(s) ahead of remote")
      fi
    else
      # No upstream, check against main/master
      DEFAULT_BRANCH=""
      if git show-ref --verify --quiet refs/heads/main; then
        DEFAULT_BRANCH="main"
      elif git show-ref --verify --quiet refs/heads/master; then
        DEFAULT_BRANCH="master"
      fi

      if [[ -n "$DEFAULT_BRANCH" ]]; then
        AHEAD=$(git rev-list --count "$DEFAULT_BRANCH"..HEAD 2>/dev/null || echo "0")
        if [[ "$AHEAD" -gt 0 ]]; then
          REMINDERS+=("🚀 Branch '$CURRENT_BRANCH' has $AHEAD commit(s) not pushed")
        fi
      fi
    fi

    # Check if there's an open PR
    if command -v gh &>/dev/null; then
      PR_STATUS=$(gh pr view --json state --jq '.state' 2>/dev/null || echo "")
      if [[ "$PR_STATUS" == "OPEN" ]]; then
        PR_URL=$(gh pr view --json url --jq '.url' 2>/dev/null || echo "")
        REMINDERS+=("📋 Open PR: $PR_URL")
      elif [[ -z "$PR_STATUS" ]] && [[ "${#REMINDERS[@]}" -gt 0 ]]; then
        REMINDERS+=("💡 Consider: gh pr create")
      fi
    fi
  fi
fi

# If we have reminders, include them in the response
if [[ "${#REMINDERS[@]}" -gt 0 ]]; then
  # Build the message
  MESSAGE="\\n━━━ Session Ending ━━━\\n"
  for reminder in "${REMINDERS[@]}"; do
    MESSAGE+="$reminder\\n"
  done
  MESSAGE+="━━━━━━━━━━━━━━━━━━━━━"

  # Output with message (approve but show reminders)
  cat << EOF
{
  "decision": "approve",
  "message": "$MESSAGE"
}
EOF
else
  echo '{"decision": "approve"}'
fi

exit 0
