---
name: tidy-your-workspace
description: >
  Clean up git branches, worktrees, stale remote refs, and forgotten stashes.
  Structural housekeeping for the repo.
category: workflow
---

# Tidy Your Workspace

Structural git cleanup. Branches, worktrees, remote refs, stashes. The stuff that accumulates when you're heads-down building.

**Announce at start:** "I'm using the tidy-your-workspace skill to clean up this repo."

## When to Use

- Branches are piling up
- Worktrees are stale
- User says "tidy up," "clean branches," "prune," "tidy your workspace"
- User invokes `/tidy-your-workspace`

## Phase 1: Detect Context

Determine what kind of repo this is:

```bash
# Check if bare repo with worktrees
git rev-parse --is-bare-repository
git worktree list
```

| Context | Behavior |
|---------|----------|
| Bare repo + worktrees | Scan all worktrees + branches |
| Standard repo | Scan branches + remote refs |
| Single worktree | Scan branches + remote refs |

## Phase 2: Gather (parallel)

Run all checks simultaneously on the **primary working directory**:

```bash
# Merged branches safe to delete
git branch --merged main | grep -v '^\*\|main$'

# Branches with no remote tracking
git branch -vv | grep ': gone]'

# Stale remote refs
git remote prune origin --dry-run

# Worktrees (if applicable)
git worktree list --porcelain

# Forgotten stashes
git stash list

# Stale worktrees (branch deleted on remote)
# For each worktree, check if its branch still exists
```

For worktree repos, check each worktree for:
- Uncommitted changes (`git -C <path> status --porcelain`)
- Branch still exists on remote
- Branch merged into main

## Phase 3: Present Findings

If everything is clean: "Workspace is tidy. Nothing to clean up."

If action is needed, present a summary table with status icons:

| Icon | Meaning |
|------|---------|
| `+` | Clean, safe to remove |
| `~` | Has uncommitted changes, needs attention |
| `!` | Stale ref or tracking gone |

Use `AskUserQuestion` with **multiselect**. One interaction.

Mark safe actions with "(Recommended)":

| Finding | Option | Notes |
|---------|--------|-------|
| Merged branches | Delete branch-name (Recommended) | Already merged into main |
| Tracking-gone branches | Delete branch-name (Recommended) | Remote branch deleted |
| Stale remote refs | Prune remote refs (Recommended) | `git remote prune origin` |
| Stale worktrees | Remove worktree-path (Recommended) | Only if clean (no uncommitted) |
| Dirty worktrees | [Flag only] | Show path + uncommitted count |
| Stashes | [Flag only] | Show age + description |

## Phase 4: Execute

For approved actions:

```bash
# Delete merged/gone branches
git branch -d <branch>

# Prune remote refs
git remote prune origin

# Remove stale worktrees
git worktree remove <path>
git worktree prune
```

## Final Summary

```
Workspace tidied.

  Branches:   3 deleted (feat/old-thing, feat/done-thing, bug/fixed-it)
  Worktrees:  1 removed (pr/123)
  Remote refs: pruned
  Stashes:    2 flagged (consider clearing)

Clean.
```

## What It Doesn't Do

- No commits or pushes — that's `/coffee-break`
- No memory saves — that's `/lunch-break`
- No multi-repo scanning — operates on current repo only
- No CLAUDE.md revision — that's `/have-a-good-evening`

## Guidelines

- **Current repo only** — focused cleanup, not a multi-repo sweep
- **One interaction** — the multiselect is the only prompt
- **Parallel gather** — all checks run simultaneously
- **Safe defaults** — only recommend deleting merged/gone branches and clean worktrees
- **Never force-delete** — use `git branch -d` (safe), not `-D` (force)
- **Flag dirty worktrees** — inform, don't offer to remove worktrees with uncommitted changes
