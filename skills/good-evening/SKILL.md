---
name: good-evening
description: >
  End-of-session cleanup. Parallel git checks across all repos, batched
  decisions, CLAUDE.md revision, and memory save.
category: workflow
---

# Have a Good Evening

End-of-session cleanup in three phases: gather, act, save.

**Announce at start:** "I'm using the good-evening skill to run end-of-session cleanup."

## When to Use

- User says "let's wrap up," "we're done," "ending for today," "good evening"
- Before closing a long session with multiple changes
- User invokes `/have-a-good-evening`

If the session was purely exploratory (no code changes), skip to **Phase 2: Save Session Learnings**.

Use `AskUserQuestion` for all interactive prompts — structured options are faster than open-ended text.

**Multi-session awareness:** Multiple Claude sessions may be working in the same repos simultaneously. Only touch changes you made in this session. If you see uncommitted work you don't recognize, leave it alone — it belongs to another session.

## Phase 1: Gather + Act

### Gather (parallel, no user interaction)

Run these checks **simultaneously across working directories you touched this session**:

```bash
git -C <repo> status --short          # Uncommitted/unstaged changes
git -C <repo> stash list              # Forgotten stashes
git -C <repo> log --oneline @{u}..    # Unpushed commits (if tracking remote)
git -C <repo> branch --merged main    # Branches safe to delete
```

Also scan for orphaned artifacts: `*.bak`, `*.old`, `*.tmp`.

For repos without a remote, skip the unpushed check and note "no remote."

### If everything is clean

Show "All repos clean" and skip to **Phase 2: Save Session Learnings**.

### If action is needed

Present a single summary table (repo, finding, recommended action) so the user can see everything at a glance:

| Finding | Default | Notes |
|---------|---------|-------|
| Uncommitted changes | Commit (Recommended) | Generate message at execution time |
| Unpushed commits | Push (Recommended) | Normal push, never force |
| Merged branches | Delete (Recommended) | Already merged (squash-merged won't show — note this) |
| Stashes | Flag only | Inform, no automatic action |
| Orphaned files | Flag only | Inform, no automatic action |

Use `AskUserQuestion` with **multiselect** so the user can deselect any actions they don't want. One question, one approval.

After approval, execute. For commits, generate a message following the project's commit conventions (check CLAUDE.md for patterns). If no conventions are loaded, use conventional commits format.

## Phase 2: Save Session Learnings

### Revise CLAUDE.md

Only update CLAUDE.md if something concrete changed this session: a new pattern established, a gotcha discovered, a tool preference confirmed. Don't update for routine work. If nothing warrants a revision, skip silently.

### Update Memory

If auto memory exists, use `AskUserQuestion` with **multiselect** — Claude proposes what it observed as options, user can add their own via "Other". Mark the strongest proposals with "(Recommended)".

Claude's proposals cover two angles:

**What went wrong** — gotchas, false assumptions, things that cost time:
- A dependency that turned out not to exist
- A config that behaves differently than documented
- An API that silently fails under certain conditions

**What we wish we knew at the start** — context that's obvious now but invisible cold:
- How a caching/versioning system actually works under the hood
- Which tool/workflow turned out to be the right one (and which didn't)
- Architectural decisions made and why

The user sees Claude's proposals, checks the ones worth keeping, and optionally adds their own. One multiselect, done.

If Claude has nothing to propose, skip silently.

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

- **Own your session** — only touch changes you made, leave unrecognized work alone
- **One approval round** — do not ask per-repo or per-action sequentially
- **Parallel gather** — all git checks simultaneously
- **Never auto-commit** — always get user approval
- **Never force-push**
- **Never delete unmerged branches** without explicit confirmation
