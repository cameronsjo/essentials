#!/bin/bash
# Environment Variable Naming Validator
# Warns about generic environment variable names
# Enforces: TOOLNAME_SETTING pattern (CLAUDE.md standards)

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // "unknown"')

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Skip .env files themselves (they define vars)
if [[ "$FILE_PATH" == *".env"* ]] || [[ "$FILE_PATH" == *"environment"* ]]; then
  exit 0
fi

# Skip documentation where we might reference these
if [[ "$FILE_PATH" =~ \.(md|txt)$ ]]; then
  exit 0
fi

# Generic environment variables to flag (not tool-prefixed)
declare -a GENERIC_VARS=(
  "DEBUG"
  "DISABLE"
  "NO_SPLASH"
  "PORT"
  "VERBOSE"
  "QUIET"
  "SILENT"
)

# Build grep pattern for problematic usage
# Match: process.env.DEBUG, os.getenv("DEBUG"), ENV["DEBUG"], etc.
GREP_PATTERN=$(IFS='|'; echo "${GENERIC_VARS[*]}")

# Look for generic env var usage in code
GENERIC_USAGE=$(echo "$CONTENT" | grep -nE "(process\.env\.|os\.getenv\(|ENV\[|getenv\().*\b($GREP_PATTERN)\b" || true)

if [ -n "$GENERIC_USAGE" ]; then
  cat >&2 << EOF
⚠️  Generic environment variable usage detected in $FILE_PATH

Found potentially problematic usage:
$GENERIC_USAGE

CLAUDE.md requires tool-prefixed environment variable names:
  ✅ MYAPP_DEBUG=1, TSPARK_DISABLE=true, SERVICE_PORT=8080
  ❌ DEBUG=1, DISABLE=true, PORT=8080

BENEFITS:
  • Prevents namespace conflicts across tools
  • Clear ownership and purpose
  • Easy to identify and grep for
  • Follows industry best practices

EXCEPTIONS:
Well-established standard vars are acceptable: PATH, HOME, USER, NO_COLOR

This is a warning - consider using tool-prefixed names.
EOF
  exit 1  # Non-blocking warning
fi

exit 0
