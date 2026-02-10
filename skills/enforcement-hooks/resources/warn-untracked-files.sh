#!/bin/bash
# Untracked File Warning
# Warns about untracked files after git add/commit operations
# Helps catch missing test files, configs, or new dependencies

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only trigger on git add/commit commands
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

if [[ ! "$COMMAND" =~ ^git\ (add|commit) ]]; then
  exit 0
fi

# Check for untracked files
UNTRACKED=$(git status --porcelain 2>/dev/null | grep '^??' || true)

if [ -z "$UNTRACKED" ]; then
  # No untracked files, all good
  exit 0
fi

# Count untracked files
UNTRACKED_COUNT=$(echo "$UNTRACKED" | wc -l | tr -d ' ')

# Check if any untracked files look important (not build artifacts)
IMPORTANT=$(echo "$UNTRACKED" | grep -vE '\.(log|tmp|cache|pyc|class|o|a|so|dylib)$' || true)

if [ -n "$IMPORTANT" ]; then
  cat >&2 << EOF
⚠️  Warning: $UNTRACKED_COUNT untracked file(s) detected after git operation

These files may need to be included in your commit:
$IMPORTANT

REVIEW:
  git status          # See all untracked files
  git add <file>      # Add files to staging
  git add -A          # Add all files (use with caution)

CLAUDE.md requires checking for untracked files that might be needed.
Review and add any critical files before committing.
EOF
  exit 1  # Non-blocking warning
fi

exit 0
