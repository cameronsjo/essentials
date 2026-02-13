---
name: wrap-up-session
description: >
  End-of-session cleanup. Parallel git checks across all repos, batched decisions,
  CLAUDE.md revision, and optional memory save. Use when the user says they're done
  or invokes /wrap-up.
category: workflow
---

# Wrap Up Session

End-of-session cleanup in two phases: gather everything in parallel, then one batched decision.

## When to Use

- User says "let's wrap up," "we're done," "ending for today"
- Before closing a long session with multiple changes
- User invokes `/wrap-up`

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

Present a single summary table (repo, finding, recommended action) with **smart defaults pre-filled**:

| Finding | Default | Notes |
|---------|---------|-------|
| Uncommitted changes | Commit | User provides message at execution time |
| Unpushed commits | Push | Safe — normal push, never force |
| Merged branches | Delete | Safe — already merged (squash-merged won't show — note this) |
| Stashes | Flag only | Inform, no automatic action |
| Orphaned files | Flag only | Inform, no automatic action |

Use `AskUserQuestion` with **multiselect** so the user can deselect any actions they don't want. One question, one approval.

After approval, execute all approved actions. For commits, generate a commit message from the changes. Show it inline — the user can reject or override via the multiselect, not a separate question.

## Save Session Learnings

### Revise CLAUDE.md

Only update CLAUDE.md if something concrete changed this session: a new pattern established, a gotcha discovered, a tool preference confirmed. Don't update for routine work. If nothing warrants a revision, skip silently.

### Update Memory

Check if a memory directory exists at `~/.claude/projects/<project-key>/memory/MEMORY.md`.

If it exists, use `AskUserQuestion` with **multiselect** — Claude proposes what it observed as options, and the user can add their own via the "Other" free-text option that AskUserQuestion provides automatically. One interaction captures both sides.

Claude's proposals should cover two angles:

**What went wrong** — gotchas, corrections, false assumptions:
- "Pillow is NOT a transitive dep of google-genai — Image.save() is pure stdlib"
- "Plugin cache invalidation requires a version bump, not just marketplace update"

**What we wish we knew at the start** — context that's obvious now but would save time cold:
- "The plugin cache is version-pinned, not content-hashed — same version = stale cache"
- "google-genai's Image class handles save() with pure stdlib — no PIL needed anywhere"
- "Prompt frontmatter is parsed by Claude in validation, pass values as CLI args to scripts"

The user sees Claude's proposals, checks the ones worth keeping, and optionally adds their own. One multiselect, done.

If Claude has nothing to propose, skip silently — don't show an empty picker.

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
