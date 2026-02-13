---
name: tidy-your-workspace
description: >
  Clean up git branches, worktrees, stale remote refs, and forgotten stashes.
  Structural housekeeping for the repo.
category: workflow
---

# Tidy Your Workspace

Structural git cleanup. Branches, worktrees, remote refs, stashes.

**Announce at start:** "I'm using the tidy-your-workspace skill to clean up branches and worktrees."

## When to Use

- Branches are piling up
- Worktrees are stale
- User says "tidy up," "clean branches," "prune," "tidy your workspace"
- User invokes `/tidy-your-workspace`

## Phase 1: Detect Context

```bash
git rev-parse --is-bare-repository
git worktree list
```

| Context | Behavior |
|---------|----------|
| Bare repo + worktrees | Scan all worktrees + branches |
| Standard repo | Scan branches + remote refs |

## Phase 2: Gather (parallel)

Run all checks simultaneously:

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
```

For worktree repos, check each worktree for:
- Uncommitted changes (`git -C <path> status --porcelain`)
- Branch still exists on remote
- Branch merged into main

## Phase 3: Present Findings

If everything is clean: "Workspace is tidy. Nothing to clean up."

If action is needed, use `AskUserQuestion` with **multiselect**. One interaction.

| Finding | Option | Notes |
|---------|--------|-------|
| Merged branches | Delete branch-name (Recommended) | Already merged into main |
| Tracking-gone branches | Delete branch-name (Recommended) | Remote branch deleted |
| Stale remote refs | Prune remote refs (Recommended) | `git remote prune origin` |
| Stale worktrees | Remove worktree-path (Recommended) | Only if clean |
| Dirty worktrees | [Flag only] | Show path + uncommitted count |
| Stashes | [Flag only] | Show age + description |

## Phase 4: Execute

```bash
git branch -d <branch>           # Merged/gone branches (safe delete)
git remote prune origin           # Stale remote refs
git worktree remove <path>        # Stale worktrees
git worktree prune                # Final cleanup
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

## Guidelines

- **Current repo only** — focused cleanup, not a multi-repo sweep
- **One interaction** — the multiselect is the only prompt
- **Never force-delete** — `git branch -d` (safe), not `-D`
- **Flag dirty worktrees** — inform, don't remove worktrees with uncommitted changes
