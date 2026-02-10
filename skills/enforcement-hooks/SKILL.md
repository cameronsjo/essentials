---
name: enforcement-hooks
description: Claude Code hooks for automated enforcement of engineering standards. Includes terminology guards, TODO blockers, security checks, and quality gates.
category: quality-security
---

# Enforcement Hooks

Automated enforcement of CLAUDE.md standards through real-time validation hooks.

## Overview

Hooks work **in conjunction** with CLAUDE.md to provide:

- **CLAUDE.md:** Strategic guidance (philosophy, patterns, judgment calls, "why")
- **Hooks:** Tactical enforcement (automated checks, blocks, warnings, "what")

## Hook Summary

| Hook | Event | Severity | Purpose |
|------|-------|----------|---------|
| `terminology-guard.sh` | PreToolUse | Block | Inclusive terminology |
| `block-orphaned-todos.sh` | PreToolUse | Block | TODO(#123) format |
| `markdown-lint.sh` | PreToolUse | Warn | Markdown quality |
| `warn-untracked-files.sh` | PostToolUse | Warn | Git hygiene |
| `validate-env-vars.sh` | PreToolUse | Warn | Env var naming |
| `validate-line-endings.sh` | PreToolUse | Warn | CRLF prevention |
| `git-safety.sh` | PreToolUse | Block | Dangerous git ops |
| `protected-files-guard.sh` | PreToolUse | Block | Lock sensitive files |
| `session-start.sh` | SessionStart | Info | Setup preferences |
| `stop-check.sh` | Stop | AI | Completion check |

## Blocking Hooks (Exit 2)

### 1. Inclusive Terminology Guard

**File:** `terminology-guard.sh`
**Blocks:** whitelist, blacklist, master branch, sanity check, dummy value, grandfathered

```bash
# BLOCKED
allowed_ips = config.get("whitelist")

# ALLOWED
allowed_ips = config.get("allowlist")
```

### 2. Orphaned TODO Blocker

**File:** `block-orphaned-todos.sh`
**Blocks:** TODO, FIXME, HACK without `(#123)` reference

```typescript
// BLOCKED
// TODO: implement caching

// ALLOWED
// TODO(#456): implement caching for user profiles
```

### 3. Git Safety

**File:** `git-safety.sh`
**Blocks:** Force push to main, dangerous git operations

### 4. Protected Files Guard

**File:** `protected-files-guard.sh`
**Blocks:** Edits to specified protected files

## Warning Hooks (Exit 1)

### 5. Markdown Lint

**File:** `markdown-lint.sh`
**Requires:** `npm install -g markdownlint-cli`

Checks markdown quality (headings, lists, code blocks).

### 6. Untracked Files Warning

**File:** `warn-untracked-files.sh`

Warns about untracked files before commits.

### 7. Environment Variable Naming

**File:** `validate-env-vars.sh`
**Warns:** Generic env var names (DEBUG, PORT, DISABLE)

```typescript
// WARNING
const debug = process.env.DEBUG;

// PREFERRED
const debug = process.env.MYAPP_DEBUG;
```

### 8. Line Ending Validator

**File:** `validate-line-endings.sh`

Prevents CRLF line endings in code files.

## Informational Hooks (Exit 0)

### 9. Session Start

**File:** `session-start.sh`

Sets environment variables with CLAUDE.md preferences at session start.

### 10. Stop Check

**File:** `stop-check.sh`

AI-powered check for incomplete work before session end.

## Installation

### 1. Copy hooks to ~/.claude/hooks/

```bash
cp resources/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

### 2. Configure in settings.json

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/terminology-guard.sh"
          },
          {
            "type": "command",
            "command": "~/.claude/hooks/block-orphaned-todos.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

## Customization

### Disable a Hook

Remove or comment out the hook in settings.json.

### Add Custom Terms

Edit the hook script directly:

```bash
# In terminology-guard.sh
declare -a PATTERNS=(
  "whitelist"
  "blacklist"
  "your-custom-term"  # Add here
)
```

### Change Severity

Change `exit 2` (blocking) to `exit 1` (warning):

```bash
# Before (blocking)
exit 2

# After (warning only)
exit 1
```

## Resources

All hook scripts are in `resources/`:
- `resources/terminology-guard.sh`
- `resources/block-orphaned-todos.sh`
- `resources/markdown-lint.sh`
- `resources/warn-untracked-files.sh`
- `resources/validate-env-vars.sh`
- `resources/validate-line-endings.sh`
- `resources/git-safety.sh`
- `resources/protected-files-guard.sh`
- `resources/session-start.sh`
- `resources/stop-check.sh`
