#!/usr/bin/env bash
# PreToolUse: Block writes to protected/sensitive files
# Triggers on Write|Edit tools

set -euo pipefail

# Read input from stdin
INPUT=$(cat)

# Extract the file path from the tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

if [[ -z "$FILE_PATH" ]]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Get just the filename for pattern matching
FILENAME=$(basename "$FILE_PATH")
FILENAME_LOWER=$(echo "$FILENAME" | tr '[:upper:]' '[:lower:]')

# Protected file patterns - BLOCK without override
BLOCKED_PATTERNS=(
  # Secrets and credentials
  ".env"
  ".env.local"
  ".env.production"
  ".env.secret"
  "credentials.json"
  "secrets.json"
  "*.key"
  "*.pem"
  "*.p12"
  "*.pfx"
  "id_rsa"
  "id_ed25519"
  "*.keystore"
  # Auth tokens
  ".npmrc"
  ".pypirc"
  ".netrc"
  ".docker/config.json"
  # Cloud credentials
  "gcloud-credentials.json"
  "service-account*.json"
)

# Warning patterns - WARN but allow
WARNING_PATTERNS=(
  # Config files that should be reviewed
  "CLAUDE.md"
  "AGENTS.md"
  ".claudeignore"
  "settings.json"
  # Lock files (usually auto-generated)
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  "Cargo.lock"
  "poetry.lock"
  "uv.lock"
  # CI/CD configs
  ".github/workflows/*.yml"
  ".github/workflows/*.yaml"
  "Jenkinsfile"
  ".gitlab-ci.yml"
)

# Check if file matches blocked patterns
for pattern in "${BLOCKED_PATTERNS[@]}"; do
  # Handle glob patterns
  if [[ "$pattern" == *"*"* ]]; then
    if [[ "$FILENAME_LOWER" == $pattern ]]; then
      cat << EOF
{
  "decision": "block",
  "reason": "🚫 BLOCKED: '$FILENAME' is a protected file (secrets/credentials).\n\nThis file type should never be modified by automation.\nIf you need to update it, do so manually outside Claude Code."
}
EOF
      exit 0
    fi
  else
    if [[ "$FILENAME_LOWER" == "$pattern" ]] || [[ "$FILE_PATH" == *"$pattern"* ]]; then
      cat << EOF
{
  "decision": "block",
  "reason": "🚫 BLOCKED: '$FILENAME' is a protected file (secrets/credentials).\n\nThis file type should never be modified by automation.\nIf you need to update it, do so manually outside Claude Code."
}
EOF
      exit 0
    fi
  fi
done

# Check if file matches warning patterns
for pattern in "${WARNING_PATTERNS[@]}"; do
  if [[ "$pattern" == *"*"* ]]; then
    if [[ "$FILENAME_LOWER" == $pattern ]] || [[ "$FILE_PATH" == *"$pattern"* ]]; then
      cat << EOF
{
  "decision": "approve",
  "message": "⚠️  Modifying config file: $FILENAME\nPlease review changes carefully before committing."
}
EOF
      exit 0
    fi
  else
    if [[ "$FILENAME_LOWER" == "$pattern" ]] || [[ "$FILE_PATH" == *"$pattern"* ]]; then
      cat << EOF
{
  "decision": "approve",
  "message": "⚠️  Modifying config file: $FILENAME\nPlease review changes carefully before committing."
}
EOF
      exit 0
    fi
  fi
done

# Allow all other files
echo '{"decision": "approve"}'
exit 0
