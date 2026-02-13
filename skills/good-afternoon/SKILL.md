---
name: good-afternoon
description: >
  Re-orient after /clear or context compaction. Reload uncommitted changes
  and recent commits to restore working context.
category: workflow
---

# Good Afternoon

Welcome back. Restore context after a break, a `/clear`, or compaction.

## When to Use

- After `/clear`
- After context compaction
- After stepping away and coming back to a running session
- User says "good afternoon," "I'm back," "what was I working on"
- User invokes `/good-afternoon`

## The Process

### 1. Git Status

Run on the **primary working directory**:

```bash
git status --short
```

Show what's uncommitted.

### 2. Read Changed Files

For each modified or new file from git status:

1. **Skip binary files** — check file extension (.png, .jpg, .pdf, .zip, etc.)
2. **Skip large files** — if file > 10k lines, note it but don't load without asking
3. **Read the file** — use Read tool to load content back into context

To identify changed files:

```bash
git diff --name-only HEAD
git ls-files --others --exclude-standard
```

Skip lock files, build artifacts, and generated code.

### 3. Recent Commits

Show the last 5 commits to jog memory:

```bash
git log --oneline -5
```

### 4. Brief Summary

```
Welcome back. You were working on:

Loaded into context:
- src/auth.ts (234 lines, modified)
- tests/auth.test.ts (89 lines, modified)
- docs/api.md (new file)

Total: 3 files, 357 lines
Skipped: 1 file (binary)

Recent commits:
- abc1234 feat: add token refresh
- def5678 fix: handle expired sessions

Ready to continue.
```

## What It Doesn't Do

- No multi-repo scanning — that's `/good-morning` or `/have-a-good-evening` scope
- No memory operations — that's `/lunch-break`
- No beads checks — that's `/good-morning`
- No commits or pushes — that's `/coffee-break`

## Guidelines

- **Primary repo only** — focus on what you were actively working on
- **Load actual content** — the point is restoring context, not just listing files
- **Skip noise** — lock files, build artifacts, generated code don't need loading
- **Be selective** — only load text files that are part of current work
