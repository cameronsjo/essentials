#!/bin/bash
# Inclusive Terminology Guardian
# Blocks Write/Edit operations that violate CLAUDE.md terminology standards
# Enforces: allowlist (not whitelist), main (not master), etc.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // "unknown"')

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Skip checking CLAUDE.md itself (where we document these terms)
if [[ "$FILE_PATH" == *"CLAUDE.md"* ]] || [[ "$FILE_PATH" == *"claude.md"* ]]; then
  exit 0
fi

# Blocklist patterns (case-insensitive)
# Using array for better readability and maintainability
declare -a PATTERNS=(
  "whitelist"
  "blacklist"
  "master branch"
  "master node"
  "master prompt"
  "master server"
  "sanity check"
  "dummy value"
  "grandfathered"
)

# Build grep pattern
GREP_PATTERN=$(IFS='|'; echo "${PATTERNS[*]}")

# Check for violations (case-insensitive, whole word match)
VIOLATIONS=$(echo "$CONTENT" | grep -inE "\b($GREP_PATTERN)\b" || true)

if [ -n "$VIOLATIONS" ]; then
  cat >&2 << EOF
🚫 BLOCKED: Inclusive terminology violation detected in $FILE_PATH

Found prohibited terms:
$VIOLATIONS

Required alternatives (CLAUDE.md NON-NEGOTIABLES):
  whitelist → allowlist
  blacklist → blocklist, denylist
  master → main, primary, leader, parent, source
  sanity check → validation check, confidence check, smoke test
  dummy value → placeholder value, sample value, mock value
  grandfathered → legacy status, exempted, inherited

See ~/.claude/CLAUDE.md NON-NEGOTIABLES section for complete policy.
EOF
  exit 2  # Blocking error
fi

exit 0
