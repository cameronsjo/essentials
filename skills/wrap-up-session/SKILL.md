---
name: wrap-up-session
description: >
  End-of-session cleanup. Parallel git checks across all repos, batched decisions,
  CLAUDE.md revision, and optional memory save. Use when the user says they're done
  or invokes /wrap-up-session.
category: workflow
---

# Wrap Up Session

End-of-session cleanup in two phases: gather everything in parallel, then one batched decision.

## When to Use

- User says "let's wrap up," "we're done," "ending for today"
- Before closing a long session with multiple changes
- User invokes `/wrap-up-session`

If the session was purely exploratory (no code changes), skip to **Save Session Learnings**.

Use `AskUserQuestion` for all interactive prompts — structured options are faster than open-ended text.

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

Show "All repos clean" and skip to **Save Session Learnings**.

### If action is needed

Present a single summary table with **recommended actions pre-filled**:

```
| Repo               | Finding              | Recommended Action |
|--------------------|----------------------|--------------------|
| claude-marketplace | 3 uncommitted files  | Commit             |
| claude-marketplace | 2 unpushed commits   | Push               |
| claude-marketplace | branch `feat/old`    | Delete (merged)    |
| local-stack        | 1 stash              | (flagged)          |
| local-stack        | 2 .bak files         | (flagged)          |
```

**Smart defaults:**

| Finding | Default | Notes |
|---------|---------|-------|
| Uncommitted changes | Commit | User provides message at execution time |
| Unpushed commits | Push | Safe — normal push, never force |
| Merged branches | Delete | Safe — already merged (squash-merged won't show — note this) |
| Stashes | Flag only | Inform, no automatic action |
| Orphaned files | Flag only | Inform, no automatic action |

Use `AskUserQuestion` with **multiselect** so the user can deselect any actions they don't want. One question, one approval.

After approval, execute all approved actions. For commits, ask for a single commit message (or generate one from the changes).

## Save Session Learnings

### Revise CLAUDE.md

Review the session for patterns, gotchas, and context that would help future sessions. Update the project's CLAUDE.md files if warranted.

### Update Memory

Check if a memory directory exists:

```
~/.claude/projects/<project-key>/memory/MEMORY.md
```

If it exists, ask:

> "Any learnings from this session to save? (Enter to skip)"

If the user provides learnings, update MEMORY.md. Keep concise — it loads into every session's system prompt (~200 line budget).

If the user skips or provides nothing, move on without asking again.

### Project-Specific Steps

Check for `.claude/wrap-up.md` in the project root. If found, run those steps after the standard checklist. These are repo-specific cleanup tasks the user has defined.

Example `.claude/wrap-up.md`:

```markdown
# Project Wrap-Up

- Run `make clean` before closing
- Ensure Docker containers are stopped: `docker compose down`
- Check for orphaned migration files in `db/migrations/`
```

## Final Summary

```
Session wrap-up complete.

  Repos:     2 clean
  Commits:   all pushed
  Branches:  1 deleted
  CLAUDE.md: updated
  Memory:    updated

Ready to close.
```

## Guidelines

- **Never auto-commit** — always get user approval via the batched decision
- **Never force-push**
- **Never delete unmerged branches** without explicit confirmation
- **Check ALL working directories** — not just the primary one
- **One approval round** — do not ask per-repo or per-action sequentially
- **Parallel gather** — run all git checks simultaneously, not sequentially
