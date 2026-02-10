# Global Git Configuration Reference

## Applied Configurations

### Rebase Improvements
- `rebase.autoStash = true` - Automatically stash uncommitted changes before rebase
- `rebase.autoSquash = true` - Automatically squash commits marked with `fixup!` or `squash!`

### Diff Improvements
- `diff.algorithm = histogram` - Better diff algorithm that produces more readable diffs
- `diff.colorMoved = zebra` - Highlight moved code blocks in different colors
- `diff.colorMovedWS = allow-indentation-change` - Ignore whitespace changes when detecting moved code

### Merge Improvements
- `merge.conflictStyle = zdiff3` - Show common ancestor in merge conflicts (easier to resolve)

### Fetch Improvements
- `fetch.prune = true` - Automatically remove deleted remote branches

### Commit Improvements
- `commit.verbose = true` - Show full diff when writing commit messages

### Branch Improvements
- `branch.sort = -committerdate` - Sort branches by most recent commit date

### Rerere (Reuse Recorded Resolution)
- `rerere.enabled = true` - Remember how you resolved merge conflicts
- `rerere.autoUpdate = true` - Automatically stage rerere resolutions

### Help Improvements
- `help.autoCorrect = prompt` - Prompt for typo corrections in git commands

### Line Ending Configuration
- `core.autocrlf = input` - Convert CRLF to LF on commit, keep LF on checkout
- `core.attributesfile = ~/.gitattributes` - Use global gitattributes for all repos

## New Aliases

### Information Aliases
- `git last` - Show last commit with stats
- `git branches` - Verbose branch list with tracking info
- `git remotes` - List all remotes with URLs
- `git contributors` - List contributors by commit count

### Log Aliases
- `git ls` - Pretty one-line log with colors
- `git ll` - Pretty log with file change statistics
- `git graph` - Pretty graph visualization of commit history

### Existing Aliases (Already Configured)
- `git history` - Show last 25 commits in short format
- `git all-branches` - Show remote branches sorted by date
- `git amend` - Amend last commit without editing message
- `git cob` - Checkout new branch
- `git unstage` - Unstage files
- `git pushup` - Push current branch and set upstream
- `git ffs` - Force reset to origin/main and clean
- `git delete-tag` - Delete tag locally and remotely

## Benefits

1. **Better conflict resolution** - `zdiff3` shows what the code looked like before both changes
2. **Cleaner remotes** - Auto-pruning removes stale branch references
3. **Better diffs** - Histogram algorithm and move detection make changes clearer
4. **Save time** - Auto-stash and rerere reduce repetitive work
5. **Better commits** - Verbose mode helps write more accurate commit messages
6. **Consistent line endings** - Global gitattributes prevent CRLF issues

## Quick Examples

```bash
# Use the pretty log
git ls

# See full graph
git graph

# Check last commit
git last

# List all branches with tracking info
git branches

# See who contributes most
git contributors
```
