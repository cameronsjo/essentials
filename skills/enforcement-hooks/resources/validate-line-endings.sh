#!/usr/bin/env bash
# Pre-tool hook: Validate line endings for shell scripts
# Blocks Write/Edit operations that would create bash scripts with CRLF line endings

set -euo pipefail

# Read the input JSON from stdin
INPUT=$(cat)

# Extract file path and content from the input
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.content // .new_string // empty')

# Skip if not a shell script
if [[ ! "$FILE_PATH" =~ \.(sh|bash)$ ]]; then
  echo '{"ok": true}'
  exit 0
fi

# Check if content contains CRLF line endings
if echo "$CONTENT" | grep -q $'\r'; then
  echo '{
    "ok": false,
    "message": "BLOCKED: Shell script contains Windows-style CRLF line endings (\\r\\n). This will cause \"env: bash\\r: No such file or directory\" errors. Use LF (\\n) line endings for bash scripts. Run: sed -i \"\" $\"s/\\r$//\" '"$FILE_PATH"' to fix."
  }'
  exit 0
fi

# All good - allow the operation
echo '{"ok": true}'
exit 0
