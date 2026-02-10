#!/bin/bash
# Markdown Quality Gate
# Runs markdownlint on markdown files before writing
# Enforces: consistent formatting, proper heading hierarchy, etc.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Only check markdown files
if [[ ! "$FILE_PATH" =~ \.md$ ]]; then
  exit 0
fi

# Only for Write operations (Edit will be validated when final Write happens)
if [[ "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Extract content and write to temp file for linting
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // ""')
TEMP_FILE=$(mktemp)
echo "$CONTENT" > "$TEMP_FILE"

# Check if markdownlint is available
if ! command -v markdownlint >/dev/null 2>&1; then
  echo "ℹ️  markdownlint not installed. Skipping markdown validation." >&2
  echo "Install: npm install -g markdownlint-cli" >&2
  rm -f "$TEMP_FILE"
  exit 0
fi

# Run markdownlint (capture output)
LINT_OUTPUT=$(markdownlint "$TEMP_FILE" 2>&1 || true)

if [ -n "$LINT_OUTPUT" ]; then
  cat >&2 << EOF
⚠️  Markdown linting issues detected in $FILE_PATH

$LINT_OUTPUT

FIX:
  markdownlint --fix $FILE_PATH

COMMON ISSUES:
  • Missing blank lines around headings/lists/code blocks
  • Inconsistent list markers (prefer -)
  • Skipped heading levels (h1 → h3 invalid, must be h1 → h2)
  • Missing language identifiers in code blocks
  • Trailing spaces

CLAUDE.md requires passing markdownlint validation.
This is a warning - fix before committing.
EOF
  rm -f "$TEMP_FILE"
  exit 1  # Non-blocking warning
fi

rm -f "$TEMP_FILE"
exit 0
