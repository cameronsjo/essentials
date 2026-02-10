#!/bin/bash
# SessionStart: Auto-Setup Development Context
# Injects CLAUDE.md preferences and helpful reminders into session environment
# Available via environment variables throughout the session

# Only works in SessionStart event
if [ -z "$CLAUDE_ENV_FILE" ]; then
  exit 0
fi

# Inject development environment preferences from CLAUDE.md
cat >> "$CLAUDE_ENV_FILE" << 'EOF'
# Python tooling preferences (CLAUDE.md: Python Standards)
export PYTHON_PACKAGE_MANAGER=uv
export PYTHON_LINTER=ruff
export PYTHON_FORMATTER=black
export PYTHON_TYPE_CHECKER=mypy

# Observability requirements (CLAUDE.md: Observability Standards)
export OBSERVABILITY_REQUIRED=true
export STRUCTURED_LOGGING_LIBS="python:structlog,js:winston|pino"
export OPENTELEMETRY_REQUIRED=true

# Git workflow preferences (CLAUDE.md: Git & PR Workflow)
export GIT_COMMIT_FORMAT=conventional
export GIT_BRANCH_STRATEGY=worktrees
export GIT_MAIN_BRANCH=main

# Quality gates and enforcement (CLAUDE.md: NON-NEGOTIABLES)
export ENFORCE_INCLUSIVE_TERMINOLOGY=true
export BLOCK_ORPHANED_TODOS=true
export BLOCK_AWS_REFERENCES=true
export MARKDOWNLINT_REQUIRED=true

# Code style preferences (CLAUDE.md: Code Style & Philosophy)
export CODE_STYLE_ASYNC_PREFERRED=true
export CODE_STYLE_FUNCTIONAL_PREFERRED=true
export CODE_STYLE_IMMUTABLE_PREFERRED=true

# Documentation standards (CLAUDE.md: Documentation Standards)
export DOC_FORMAT=markdown
export DOC_RFC2119_REQUIRED=true
export DOC_DIAGRAMS_ENCOURAGED=true

# Testing philosophy (CLAUDE.md: Testing Standards)
export TEST_INTEGRATION_PREFERRED=true
export TEST_FOCUS=behavior_not_implementation

# Date/Time handling (CLAUDE.md: Date and Time Handling)
export DATETIME_BACKEND_UTC_REQUIRED=true
export DATETIME_STORAGE_FORMAT="ISO_8601"
export DATETIME_TIMEZONE_AWARE_REQUIRED=true
export DATETIME_USER_FACING_LOCALIZED=true
EOF

# Get current date and time info
CURRENT_DATE=$(date "+%Y-%m-%d")
CURRENT_TIME=$(date "+%H:%M:%S %Z")
DAY_OF_WEEK=$(date "+%A")

# Get git status if in a repo
GIT_INFO=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  MODIFIED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  # Build git info line
  GIT_INFO="  • Branch: $BRANCH"

  if [[ "$STAGED" -gt 0 ]] || [[ "$MODIFIED" -gt 0 ]] || [[ "$UNTRACKED" -gt 0 ]]; then
    STATUS_PARTS=()
    [[ "$STAGED" -gt 0 ]] && STATUS_PARTS+=("$STAGED staged")
    [[ "$MODIFIED" -gt 0 ]] && STATUS_PARTS+=("$MODIFIED modified")
    [[ "$UNTRACKED" -gt 0 ]] && STATUS_PARTS+=("$UNTRACKED untracked")
    GIT_INFO+="\n  • Changes: $(IFS=', '; echo "${STATUS_PARTS[*]}")"
  else
    GIT_INFO+="\n  • Status: clean"
  fi

  # Check for open PR
  if command -v gh &>/dev/null; then
    PR_URL=$(gh pr view --json url --jq '.url' 2>/dev/null || echo "")
    if [[ -n "$PR_URL" ]]; then
      GIT_INFO+="\n  • Open PR: $PR_URL"
    fi
  fi
fi

# Output success message (shown to Claude in SessionStart context)
cat >&2 << EOF
✅ Development environment initialized with CLAUDE.md standards

📅 Session Context:
  • Today: $DAY_OF_WEEK, $CURRENT_DATE at $CURRENT_TIME
  • Working directory: $(pwd)
  • User: $(whoami)
$(echo -e "$GIT_INFO")

Active preferences:
  • Python: uv + ruff + black + mypy
  • Observability: structured logging + OpenTelemetry
  • Git: conventional commits + worktrees strategy
  • Date/Time: UTC backend, timezone-aware conversions for users
  • Quality: inclusive terminology, no orphaned TODOs, no AWS refs
  • Docs: markdown + RFC 2119 + diagrams encouraged
  • Testing: integration-first, behavior-focused

Hooks active: protected-files, git-safety, terminology-guard, orphaned-todos, markdown-lint
EOF

exit 0
