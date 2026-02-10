# Git Clone Worktree Wrapper

**Location**: `~/.claude/bin/git-clone`
**Purpose**: Override `git clone` to use worktree setup by default

## How It Works

When you run `git clone`, this wrapper intercepts it and:

1. **Default behavior**: Creates a bare repository + worktree setup
2. **With `--simple`**: Uses normal `git clone` behavior

## Usage

### Worktree Setup (Default)

```bash
git clone https://github.com/user/repo.git
```

**What happens:**
```
repo.git/                    # Bare repository (git metadata)
└── main/                    # Worktree for main branch
    ├── .git                 # Points to ../
    └── <your files>
```

**Benefits:**
- Work on multiple branches simultaneously
- No stashing or branch switching
- Each worktree has its own working directory
- Clean separation of concerns

### Normal Clone (Simple Mode)

```bash
git clone --simple https://github.com/user/repo.git
```

**What happens:**
```
repo/                        # Normal clone
├── .git/                    # Git directory
└── <your files>
```

## Examples

### Example 1: Clone with Worktree Setup

```bash
$ git clone https://github.com/anthropics/claude-code.git

📦 Cloning repository with worktree setup...

Repository: https://github.com/anthropics/claude-code.git
Bare repo:  claude-code.git

1. Creating bare repository...
Cloning into bare repository 'claude-code.git'...
done.

2. Detecting default branch...
   Default branch: main

3. Creating worktree for 'main'...
Preparing worktree (new branch 'main')
done.

✅ Repository cloned with worktree setup!

Structure:
  claude-code.git/              # Bare repository (git metadata)
  claude-code.git/main/         # Worktree for main branch

Next steps:
  cd claude-code.git/main
```

### Example 2: Create Additional Worktrees

```bash
cd claude-code.git

# Create feature worktree
git worktree add -b feat/auth-system feat/auth-system origin/main

# Create PR review worktree (detached)
git worktree add --detach pr/123 origin/some-branch

# List all worktrees
git worktree list
```

**Result:**
```
claude-code.git/
├── main/                    # Worktree for main
├── feat/
│   └── auth-system/         # Feature worktree
└── pr/
    └── 123/                 # PR review worktree
```

**Or use the helper script:**
```bash
git-smart-worktree create feat auth-system
git-smart-worktree create pr 123
```

### Example 3: Work on Multiple Branches Simultaneously

```bash
# Terminal 1: Work on main
cd claude-code.git/main
npm run dev

# Terminal 2: Work on feature (no conflicts!)
cd claude-code.git/feat/auth-system
npm test

# Terminal 3: Review PR (no stashing needed!)
cd claude-code.git/pr/123
vim src/changes.ts
```

### Example 4: Normal Clone (When Needed)

```bash
# Sometimes you just want a simple clone
git clone --simple https://github.com/user/small-repo.git

# Result: normal clone
small-repo/
├── .git/
└── <files>
```

## When to Use Which Mode

### Use Worktree Setup (Default) When:
- ✅ Active development with multiple branches
- ✅ Long-running feature branches
- ✅ Need to test across branches
- ✅ Hotfixes while working on features
- ✅ Large repositories (saves disk space - single .git)

### Use Simple Mode (`--simple`) When:
- 📝 Quick one-off clones
- 📝 Deployment/CI environments
- 📝 Small repositories
- 📝 Just reading code (not developing)
- 📝 Following external tutorials (expect normal structure)

## Installation

The wrapper is automatically installed in `~/.claude/bin/git-clone`.

**PATH Configuration** (already done in `~/.zshrc`):
```bash
export PATH="${HOME}/.claude/bin:${PATH}"
```

This places `~/.claude/bin` **before** system paths, so `git-clone` is found first.

## How Git Finds It

Git has a special feature: when you run `git <command>`, it looks for `git-<command>` in PATH.

1. You run: `git clone <url>`
2. Git searches PATH for: `git-clone`
3. Finds: `~/.claude/bin/git-clone` (our wrapper)
4. Wrapper decides: worktree setup or call `/usr/bin/git clone`

## Worktree Commands Reference

### Create Worktree

```bash
# From existing remote branch
git worktree add <branch-name>

# Create new branch + worktree
git worktree add -b <new-branch> <directory>

# From specific commit
git worktree add <directory> <commit-hash>
```

### List Worktrees

```bash
git worktree list

# Output:
# /path/to/repo.git/main         abc123 [main]
# /path/to/repo.git/feature      def456 [feature]
```

### Remove Worktree

```bash
# Remove worktree (must have no uncommitted changes)
git worktree remove <directory>

# Force remove (even with uncommitted changes)
git worktree remove --force <directory>
```

### Move Worktree

```bash
git worktree move <worktree> <new-path>
```

### Prune Worktrees

```bash
# Clean up stale worktree references
git worktree prune
```

## Advantages of Worktree Setup

### 1. **Parallel Development**
Work on main, feature, and hotfix simultaneously without conflicts.

### 2. **No Stashing**
Switch context instantly by changing directories, no `git stash` needed.

### 3. **Disk Space Efficiency**
Single `.git` directory shared across all worktrees.

### 4. **CI/CD Friendly**
Each worktree can have its own build artifacts, node_modules, etc.

### 5. **Clean History**
Less branch switching means cleaner reflog and less confusion.

## Disadvantages & When to Avoid

### ❌ Avoid for:
- Tutorials expecting standard structure
- Simple scripts/automation (unless worktree-aware)
- Quick disposable clones
- Repositories you'll only use once

### ⚠️ Considerations:
- IDEs might need configuration (usually auto-detect)
- Some tools expect `.git` as directory, not file
- Slightly different directory structure to learn

## Comparison

### Traditional Clone
```bash
repo/
├── .git/            # 200 MB
└── files

# To work on branch: git checkout feature (stash changes)
# One working directory at a time
```

### Worktree Setup
```bash
repo.git/            # 200 MB (shared)
├── main/
│   └── files
├── feat/
│   └── auth-system/
└── pr/
    └── 123/

# To work on branch: cd ../feat/auth-system (instant)
# Multiple working directories simultaneously
```

## Troubleshooting

### Wrapper Not Running

```bash
# Check PATH
echo $PATH | grep .claude/bin

# Should output: ...:/Users/<you>/.claude/bin:...

# If not, reload shell
source ~/.zshrc
```

### Want Original Git Clone

```bash
# Use --simple flag
git clone --simple <url>

# Or call git directly
/usr/bin/git clone <url>
```

### Accidentally Created Worktree When You Wanted Simple

```bash
# Remove the bare repo
rm -rf repo.git

# Clone again with --simple
git clone --simple <url>
```

## See Also

- Git Worktrees in CLAUDE.md: Section on Git & PR Workflow
- Official Git Worktree Docs: `git help worktree`
- `/clean-branches` command: Works with worktrees

---

**Last Updated**: 2026-02-04
**Version**: 2.0
**Author**: Claude Code
