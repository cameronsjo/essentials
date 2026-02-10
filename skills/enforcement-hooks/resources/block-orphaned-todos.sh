#!/bin/bash
# Orphaned TODO/FIXME Blocker
# Prevents committing code with TODO/FIXME/HACK without GitHub issue references
# Enforces: TODO(#123) format required (CLAUDE.md NON-NEGOTIABLES)

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // "unknown"')

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Skip non-code files (markdown, text, config files where TODOs are acceptable)
if [[ "$FILE_PATH" =~ \.(md|txt|json|yml|yaml|toml|ini|env)$ ]]; then
  exit 0
fi

# Skip documentation directories
if [[ "$FILE_PATH" =~ ^(docs|documentation)/ ]]; then
  exit 0
fi

# Define code markers that require issue references
declare -a MARKERS=(
  "TODO"
  "FIXME"
  "HACK"
  "XXX"
  "REFACTOR"
  "BUG"
  "OPTIMIZE"
)

# Build grep pattern for markers followed by colon (not followed by (#digits))
# This catches: "TODO:" or "TODO :" but not "TODO(#123):"
MARKER_PATTERN=$(IFS='|'; echo "${MARKERS[*]}")

# Find orphaned markers (has marker: but no (#123) reference)
ORPHANED=$(echo "$CONTENT" | grep -nE "($MARKER_PATTERN)\s*:" | grep -v '(#[0-9]+)' || true)

if [ -n "$ORPHANED" ]; then
  cat >&2 << EOF
🚫 BLOCKED: Orphaned code markers detected in $FILE_PATH

Found markers without GitHub issue references:
$ORPHANED

REQUIRED FORMAT (CLAUDE.md NON-NEGOTIABLES):
  ✅ // TODO(#123): implement caching for user profiles
  ✅ // FIXME(#456): resolve race condition in auth flow
  ✅ // HACK(#789): temporary workaround until API v2 release
  ❌ // TODO: implement caching (BLOCKED - no issue reference)
  ❌ // FIXME: this is broken (BLOCKED - no issue reference)

PROCESS:
1. Create GitHub issue with description/priority/context
2. Add code marker with issue reference

This is a NON-NEGOTIABLE requirement enforced by pre-commit hooks.
EOF
  exit 2  # Blocking error
fi

exit 0
