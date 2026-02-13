---
name: coffee-break
description: >
  Quick code checkpoint. Git status scan, stash check, commit and push
  uncommitted work. No memory operations.
category: workflow
---

# Coffee Break

Mid-session code housekeeping. Commit what's ready, push what's committed, flag what's stashed.

**Announce at start:** "I'm using the coffee-break skill to checkpoint the code."

## When to Use

- Natural pause point between tasks
- Before switching context to a different project
- User says "coffee break," "let's commit," "checkpoint"
- User invokes `/coffee-break`

## The Process

### 1. Git Status Scan (parallel)

Run across **all working directories** simultaneously:

```bash
git -C <repo> status --short          # Uncommitted changes
git -C <repo> log --oneline @{u}..    # Unpushed commits (if tracking remote)
git -C <repo> stash list              # Forgotten stashes
```

### 2. Present Findings

If everything is clean across all repos: "All clean. Enjoy your coffee."

If action is needed, use `AskUserQuestion` with **multiselect**. One interaction, one approval.

Mark safe defaults with "(Recommended)":

| Finding | Option Label | Notes |
|---------|-------------|-------|
| Uncommitted changes in repo X | Commit repo-name (Recommended) | Generate message from changes |
| Unpushed commits in repo X | Push repo-name (Recommended) | Normal push, never force |
| Stashes in repo X | [Flag only] | Inform in description, no action option |

### 3. Execute

For approved commits: generate a commit message from the changes, show inline.

For approved pushes: `git push` (pull first if behind).

## What It Doesn't Do

- No memory saves — that's `/lunch-break`
- No CLAUDE.md revision — that's `/have-a-good-evening`
- No branch cleanup — that's `/have-a-good-evening`
- No multi-Claude check — that's `/have-a-good-evening`
- No orphaned artifact scan — that's `/have-a-good-evening`

## Guidelines

- **Quick** — 1-2 minutes, not 5
- **One interaction max** — the multiselect is the only prompt
- **Parallel gather** — hit all repos simultaneously
- **Never force-push**
- **Never auto-commit** — always get approval via the multiselect
