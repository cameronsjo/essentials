---
name: good-evening
description: >
  End-of-session cleanup. Multi-Claude awareness, parallel git checks across
  all repos, batched decisions, CLAUDE.md revision, and memory save.
category: workflow
---

# Have a Good Evening

End-of-session cleanup in three phases: safety check, gather and act, save learnings.

## When to Use

- User says "let's wrap up," "we're done," "ending for today," "good evening"
- Before closing a long session with multiple changes
- User invokes `/have-a-good-evening`

If the session was purely exploratory (no code changes), skip to **Phase 3: Save Session Learnings**.

Use `AskUserQuestion` for all interactive prompts — structured options are faster than open-ended text.

## Phase 0: Multi-Claude Check

Before touching anything, check for other Claude Code instances:

```bash
pgrep -af "claude" | grep -v $$ | head -20
```

If other instances are detected:

- **Warn**: "Other Claude instances may be active in these directories"
- **Ask** via `AskUserQuestion`: "Continue with cleanup? Other instances may have uncommitted work"
  - "Continue (Recommended)" — proceed with cleanup
  - "Abort" — stop gracefully, no cleanup

If user chooses abort, end with: "No cleanup performed. Have a good evening."

If no other instances, proceed silently.

## Phase 1: Gather (parallel, no user interaction)

Run these checks **simultaneously across all working directories** using parallel bash calls:

```bash
git -C <repo> status --short          # Uncommitted/unstaged changes
git -C <repo> stash list              # Forgotten stashes
git -C <repo> log --oneline @{u}..    # Unpushed commits (if tracking remote)
git -C <repo> branch --merged main    # Branches safe to delete
```

Also scan for orphaned artifacts: `*.bak`, `*.old`, `*.tmp`.

For repos without a remote, skip the unpushed check and note "no remote."

## Phase 2: Present + Act (one interaction)

### If everything is clean

Show "All repos clean" and skip to **Phase 3: Save Session Learnings**.

### If action is needed

Present a single summary table (repo, finding, recommended action) with **smart defaults pre-filled**:

| Finding | Default | Notes |
|---------|---------|-------|
| Uncommitted changes | Commit (Recommended) | Generate message at execution time |
| Unpushed commits | Push (Recommended) | Normal push, never force |
| Merged branches | Delete (Recommended) | Already merged (squash-merged won't show — note this) |
| Stashes | Flag only | Inform, no automatic action |
| Orphaned files | Flag only | Inform, no automatic action |

Use `AskUserQuestion` with **multiselect** so the user can deselect any actions they don't want. One question, one approval.

After approval, execute all approved actions. For commits, generate a commit message from the changes. Show it inline — the user can reject or override via the multiselect, not a separate question.

## Phase 3: Save Session Learnings

### Revise CLAUDE.md

Only update CLAUDE.md if something concrete changed this session: a new pattern established, a gotcha discovered, a tool preference confirmed. Don't update for routine work. If nothing warrants a revision, skip silently.

### Update Memory

Check if a memory directory exists at `~/.claude/projects/<project-key>/memory/MEMORY.md`.

If it exists, use `AskUserQuestion` with **multiselect** — Claude proposes what it observed as options, and the user can add their own via the "Other" free-text option that AskUserQuestion provides automatically. One interaction captures both sides.

Mark the strongest proposals with "(Recommended)".

Claude's proposals should cover two angles:

**What went wrong** — gotchas, false assumptions, things that cost time:
- A dependency that turned out not to exist
- A config that behaves differently than documented
- An API that silently fails under certain conditions

**What we wish we knew at the start** — context that's obvious now but invisible cold:
- How a caching/versioning system actually works under the hood
- Which tool/workflow turned out to be the right one (and which didn't)
- Architectural decisions made and why

The user sees Claude's proposals, checks the ones worth keeping, and optionally adds their own. One multiselect, done.

If Claude has nothing to propose, skip silently — don't show an empty picker.

### Project-Specific Steps

Check for `.claude/wrap-up.md` in the project root. If found, run those steps after the standard checklist. These are repo-specific cleanup tasks the user has defined.

## Final Summary

```
Good evening. Here's what we wrapped up:

  Repos:     12 clean, 2 tidied
  Commits:   all pushed
  Branches:  1 deleted
  Memory:    updated

See you tomorrow.
```

## Guidelines

- **Never auto-commit** — always get user approval via the batched decision
- **Never force-push**
- **Never delete unmerged branches** without explicit confirmation
- **Check ALL working directories** — not just the primary one
- **One approval round** — do not ask per-repo or per-action sequentially
- **Parallel gather** — run all git checks simultaneously, not sequentially
- **Multi-Claude safety** — always check for other instances before cleanup
