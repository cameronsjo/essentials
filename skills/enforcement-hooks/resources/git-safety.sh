#!/usr/bin/env bash
# PreToolUse: Block dangerous git operations
# Triggers on Bash tool when command contains 'git'

set -euo pipefail

# Read input from stdin
INPUT=$(cat)

# Extract the command from the tool input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if [[ -z "$COMMAND" ]]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Only check git commands
if [[ "$COMMAND" != *"git"* ]]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Normalize command for matching
COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

# BLOCKED: Destructive operations that should never run
BLOCKED_COMMANDS=(
  # Force push to protected branches
  "git push --force origin main"
  "git push --force origin master"
  "git push -f origin main"
  "git push -f origin master"
  "git push origin main --force"
  "git push origin master --force"
  "git push origin main -f"
  "git push origin master -f"
  # Hard reset (loses uncommitted work)
  "git reset --hard"
  "git checkout -- ."
  # Clean with force (deletes untracked files)
  "git clean -fd"
  "git clean -df"
  "git clean -f"
  # Dangerous reflog operations
  "git reflog expire --expire=now --all"
  "git gc --prune=now"
  # Rebase main/master (rewrites history)
  "git rebase.*main"
  "git rebase.*master"
  # Force delete branches
  "git branch -D main"
  "git branch -D master"
)

# Check for blocked commands
for blocked in "${BLOCKED_COMMANDS[@]}"; do
  if [[ "$COMMAND_LOWER" =~ $blocked ]]; then
    cat << EOF
{
  "decision": "block",
  "reason": "🚫 BLOCKED: Dangerous git operation detected.\n\nCommand: $COMMAND\n\nThis operation could cause data loss or rewrite shared history.\nIf you really need to do this, run it manually outside Claude Code."
}
EOF
    exit 0
  fi
done

# WARN: Operations that need review
WARNING_PATTERNS=(
  "git push --force"
  "git push -f"
  "git reset"
  "git rebase"
  "git commit --amend"
  "git stash drop"
  "git stash clear"
  "git branch -d"
  "git branch -D"
  "git remote remove"
  "git remote rm"
)

for pattern in "${WARNING_PATTERNS[@]}"; do
  if [[ "$COMMAND_LOWER" == *"$pattern"* ]]; then
    cat << EOF
{
  "decision": "approve",
  "message": "⚠️  Git operation may modify history or lose work: $COMMAND\nReview carefully before proceeding."
}
EOF
    exit 0
  fi
done

# Allow all other git commands
echo '{"decision": "approve"}'
exit 0
