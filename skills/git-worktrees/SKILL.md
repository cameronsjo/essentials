---
name: git-workflow-tools
description: >
  Git productivity tools for cloning, worktree management, and branch workflows.
  Suggest when: user needs isolation for feature work, PR review, or parallel development.
  Not every repo needs worktrees — offer as an option, don't enforce.
category: development-workflow
---

# Git Workflow Tools

Unified skill for git cloning infrastructure and worktree workflow management.

**Announce at start:** "I'm using git-workflow-tools to [create a worktree / set up the repo / etc.]"

## When to Use This Skill

**Suggest worktrees when:**
- User wants to review a PR without disrupting current work
- User has uncommitted changes and needs to context-switch
- Parallel development on multiple features would help
- User explicitly asks for isolation or worktrees

**Don't push worktrees when:**
- User just wants to switch branches normally
- Repo uses standard clone (not bare repo structure)
- Task is simple and doesn't need isolation
- User declines the suggestion

**Key principle:** Offer worktrees as an option, explain the benefit, let user decide.

## Directory Structure

Repos cloned with `git-smart-clone` use this structure:

```
~/Projects/{host}/{org}/{repo}.git/    # Bare repo container
├── main/                               # Main branch worktree
├── feat/                               # Feature worktrees
│   ├── auth-system/
│   └── billing-api/
├── pr/                                 # PR review worktrees
│   ├── 123/
│   └── 456/
├── bug/                                # Bug fix worktrees
│   └── login-crash/
├── exp/                                # Experiments
│   └── new-architecture/
├── hot/                                # Hotfixes
│   └── urgent-prod-fix/
└── rel/                                # Release branches
    └── 1-2-0/
```

### Worktree Types

| Type | Purpose | Branch Pattern |
|------|---------|----------------|
| `feat` | Feature development | `feat/{slug}` |
| `bug` | Bug fixes | `bug/{slug}` |
| `pr` | PR review (detached) | N/A |
| `exp` | Experiments | `exp/{slug}` |
| `hot` | Urgent hotfixes | `hot/{slug}` |
| `rel` | Release branches | `rel/{version}` |

---

## /worktree Command

### Create Worktrees

```bash
/worktree create feat auth-system        # Feature worktree
/worktree create pr 123                  # PR review (auto-fetches via gh)
/worktree create bug login-crash         # Bug fix
/worktree create exp new-caching         # Experiment
/worktree create hot prod-fix            # Hotfix
/worktree create rel 1-2-0               # Release branch
```

### Management

```bash
/worktree list                           # Show all worktrees
/worktree remove feat/auth-system        # Clean up worktree
/worktree setup                          # Install deps in current worktree
```

### Natural Language Triggers

| User Says | Action |
|-----------|--------|
| "create a worktree for feature X" | Create feat worktree |
| "let's tackle PR 123" | Create PR review worktree |
| "review this PR: {url}" | Extract PR number, create worktree |
| "start fresh on a new branch" | Create feat worktree |
| "what worktrees do I have?" | List worktrees |
| "clean up my worktrees" | List + suggest removals |

---

## Operation Behaviors

### Create Feature/Bug/Exp/Hot/Rel Worktree

```
User: /worktree create feat auth-system

Claude:
  → Detecting repo structure...
  → Repo: ~/Projects/.../repo.git/
  → Fetching latest from origin...
  → Creating branch: feat/auth-system (from origin/main)
  → Creating worktree at feat/auth-system/

✓ Worktree ready at ~/Projects/.../repo.git/feat/auth-system/

Next: cd there and start coding, or say "set up for development" to install deps.
```

**Steps:**
1. Detect repo root (find nearest bare `.git` repo)
2. Run `git fetch --all --prune`
3. Create branch `{type}/{slug}` from `origin/main` (or default branch)
4. Run `git worktree add {type}/{slug} {type}/{slug}`
5. Report path — do NOT auto-install deps

### Create PR Review Worktree

```
User: /worktree create pr 123

Claude:
  → Fetching PR #123 via gh CLI...
  → PR: "Update CLAUDE.md" by @teammate
  → Branch: add-claude-md
  → Fetching branch from origin...
  → Creating detached worktree at pr/123/

✓ Worktree ready at ~/Projects/.../repo.git/pr/123/
  Branch: add-claude-md (detached)

Tip: This is read-only review mode. To push changes, check out the branch normally.
```

**Steps:**
1. Run `gh pr view 123 --json headRefName,title,author` to get PR info
2. Fetch the PR branch from origin
3. Create worktree with `--detach` (signals "review mode")
4. Report PR title/author for context

**Note:** For enterprise GitHub, use `GH_HOST=<your-enterprise-host> gh pr view ...`

### List Worktrees

```
User: /worktree list

Claude:
Worktrees in repo.git:

  main/                 ✓ main (clean)
  feat/auth-system/     ✓ feat/auth-system (3 uncommitted files)
  pr/123/               ◇ detached @ a1b2c3d
  bug/login-crash/      ✓ bug/login-crash (clean)

Stale (branch merged/deleted):
  feat/old-feature/     ⚠ branch no longer exists — remove?
```

**Steps:**
1. Run `git worktree list --porcelain`
2. For each worktree, check status with `git -C {path} status --porcelain`
3. Identify stale worktrees (branch deleted or merged)
4. Suggest cleanup for stale ones

### Remove Worktree

```
User: /worktree remove feat/auth-system

Claude:
  → Checking for uncommitted changes...
  → Worktree is clean
  → Removing worktree...
  → Pruning stale references...

✓ Removed feat/auth-system/
  Branch feat/auth-system still exists. Delete it too? (y/n)
```

**Steps:**
1. Check for uncommitted changes — warn if dirty
2. Run `git worktree remove {path}`
3. Run `git worktree prune`
4. Optionally offer to delete the branch with `git branch -d {branch}`

---

## Optional Setup

When user says "set up for development" or `/worktree setup`:

```
User: set up for development

Claude:
  → Detecting project type...
  → Found: package.json (Node.js)
  → Installing dependencies with pnpm...

✓ Dependencies installed

  → Checking for .env file...
  → Symlinked .env from ../main/.env

✓ Ready for development
```

### Detection & Actions

| Detected | Action |
|----------|--------|
| `package.json` | `pnpm install` (prefer pnpm > yarn > npm) |
| `pyproject.toml` | `uv sync` or `poetry install` |
| `requirements.txt` | `uv pip install -r requirements.txt` |
| `Cargo.toml` | `cargo build` (optional, can be slow) |
| `go.mod` | `go mod download` |
| `.env` in main/ | Symlink to current worktree |
| `.envrc` in main/ | Symlink + `direnv allow` |

**Important:** Setup is NOT automatic — only runs on explicit request.

---

## git-smart-clone

Smart git clone with auto-organization into `~/Projects/{host}/{org}/{repo}.git` structure.

### Features

- **Auto-organization**: Organizes repos by host/org automatically
- **Worktree setup**: Default uses bare repo + worktrees
- **SSH conversion**: `--ssh` flag converts HTTPS to SSH URLs
- **Simple mode**: `--simple` for standard clone when needed

### Usage

```bash
# Default: bare repo with main worktree, organized by host/org
git-smart-clone https://github.com/anthropics/claude-code.git
# Creates: ~/Projects/github.com/anthropics/claude-code.git/main/

# Simple clone (no worktree structure)
git-smart-clone --simple https://github.com/user/repo.git
# Creates: ~/Projects/github.com/user/repo/

# Convert HTTPS to SSH
git-smart-clone --ssh https://github.com/user/repo.git

# Verbose output
git-smart-clone -v https://github.com/user/repo.git
```

### When to Use Worktree vs Simple

**Use Default (Worktree):**
- Active development with multiple branches
- Need to test/compare across branches
- Long-running feature branches
- Parallel AI agent development

**Use `--simple`:**
- Quick one-off clones
- Just reading code
- CI/CD environments
- Following tutorials (expect standard structure)

---

## Raw Git Worktree Commands

For manual worktree management:

```bash
# Create worktree (from repo.git/ directory)
git worktree add feat/my-feature -b feat/my-feature origin/main

# Create detached worktree (for PR review)
git worktree add --detach pr/123 origin/branch-name

# List all worktrees
git worktree list

# Remove worktree
git worktree remove feat/my-feature

# Clean up stale references
git worktree prune

# Lock worktree (prevent accidental pruning)
git worktree lock feat/important --reason "Long-running work"

# Unlock worktree
git worktree unlock feat/important

# Repair worktree (after moving directories)
git worktree repair
```

---

## Installation

### Helper Scripts (Optional)

The skill works without scripts — these are for terminal convenience.

```bash
# Copy scripts to PATH
cp resources/git-smart-clone ~/.local/bin/
cp resources/git-smart-worktree ~/.local/bin/
chmod +x ~/.local/bin/git-smart-*

# Add to PATH (if not already)
export PATH="$HOME/.local/bin:$PATH"

# Optional aliases
alias gsc='git-smart-clone'
alias gw='git-smart-worktree'
```

### Script Usage

```bash
# git-smart-clone
gsc https://github.com/user/repo.git

# git-smart-worktree
gw create feat auth-system
gw create pr 123
gw list
gw remove feat/auth-system
gw setup
```

---

## Resources

### Scripts
- `resources/git-smart-clone` - Python script for smart cloning
- `resources/git-smart-worktree` - Shell script for worktree management

### Documentation
- `resources/git-clone-worktree-wrapper.md` - Comprehensive worktree guide
- `resources/git-config-reference.md` - Recommended git configuration

---

## Integration

This skill is called by other workflows:

| Skill | Integration Point |
|-------|-------------------|
| **brainstorming** | After design approval → creates worktree for implementation |
| **executing-plans** | Creates isolated worktree before executing |
| **finishing-a-development-branch** | Guides cleanup: merge/PR, then remove worktree |

---

## Not Every Repo Needs Worktrees

Use worktrees when you need:
- Parallel development on multiple features
- PR review without disrupting current work
- Context switching with uncommitted changes
- AI agents working in parallel

Skip worktrees for:
- Simple repos with linear development
- Documentation-only repos
- Repos you're just reading/exploring
