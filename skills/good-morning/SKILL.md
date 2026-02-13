---
name: good-morning
description: >
  Start-of-day orientation. Read-only scan of git status, recent activity,
  memory context, and open issues across all working directories.
category: workflow
---

# Good Morning

Orient at the start of a session. Read-only — no commits, no pushes, no memory saves.

**Announce at start:** "I'm using the good-morning skill to orient for today's session."

## When to Use

- Start of a new day/session
- User says "good morning," "what's on my desk," "where are we"
- User invokes `/good-morning`

## The Process

### 1. Read Memory Context

If auto memory exists, read it and surface key context: gotchas, decisions, where things left off. Keep it to 3-5 bullet points — the highlights reel.

### 2. Git Status Scan (parallel)

Run across **all working directories** simultaneously:

```bash
git -C <repo> status --short
git -C <repo> log --oneline @{u}.. 2>/dev/null  # unpushed commits
```

For each repo with findings, note:
- Uncommitted changes (count of files)
- Unpushed commits (count)
- No remote (if applicable)

Skip clean repos silently.

### 3. Recent Activity

For repos with changes or unpushed commits:

```bash
git -C <repo> log --oneline -5
```

### 4. Open Issues

If beads is initialized (`.beads/` exists):

```bash
bd list --status open,in_progress
```

If beads isn't present, skip silently.

### 5. Orient Summary

```
Good morning. Here's what's on your desk.

  Memory:    3 notes from last session
  Repos:     2 with uncommitted work, 1 with unpushed commits
  Issues:    2 open, 1 in progress
```

Then the details per repo.

## Guidelines

- **Read-only** — this command changes nothing
- **Parallel scans** — hit all repos simultaneously
- **Skip clean repos** — only surface what has something to report
