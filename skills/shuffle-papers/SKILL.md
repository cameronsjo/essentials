---
name: shuffle-papers
description: >
  Sort, standardize, and triage documentation. Fix naming conventions, heading
  hierarchy, frontmatter consistency, and organizational structure.
category: workflow
---

# Shuffle Papers

Documentation housekeeping. Find the mess, sort it out, standardize what's drifted.

**Announce at start:** "I'm using the shuffle-papers skill to tidy up the documentation."

## When to Use

- Docs have grown organically and need organizing
- Naming conventions have drifted
- User says "shuffle papers," "organize docs," "triage documentation"
- User invokes `/shuffle-papers`

## Phase 1: Scan

Find all documentation files in the project:

```bash
# Markdown files
git ls-files '*.md'

# Check for docs/ directory
ls docs/ 2>/dev/null

# Check for ADRs
ls docs/adr/ 2>/dev/null
```

Read each file's first 20 lines to capture frontmatter and title.

## Phase 2: Analyze

Check each file against these standards:

### Naming Conventions

| Location | Convention | Example |
|----------|-----------|---------|
| Root level | SCREAMING_SNAKE_CASE | `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md` |
| Everywhere else | kebab-case | `getting-started.md`, `api-overview.md` |
| ADRs | Numeric prefix + kebab-case | `0001-initial-architecture.md` |

Flag violations: `GettingStarted.md`, `API_Overview.md`, `camelCase.md`.

### Heading Hierarchy

- First heading should be `#` (h1)
- No skipped levels (`#` to `###` without `##`)
- One h1 per file

### Frontmatter Consistency

For files with YAML frontmatter:
- Check required fields exist (varies by type)
- Check field naming consistency across files

### Structural Issues

- Files in wrong location (e.g., deep docs at root level, ADRs outside `docs/adr/`)
- Missing standard files (README, CONTRIBUTING, CHANGELOG, LICENSE)
- Orphaned docs (referenced by nothing, reference nothing)
- Duplicate content (similar titles or content across files)

### Markdown Quality

- Blank lines around headings, lists, code blocks
- Consistent list markers (`-` preferred)
- Code blocks have language identifiers
- No trailing whitespace on non-empty lines

## Phase 3: Present Findings

Group issues by severity:

**Structural** — wrong location, missing files, duplicates
**Naming** — convention violations
**Content** — heading hierarchy, frontmatter, markdown quality

Use `AskUserQuestion` with **multiselect**. Present each fixable issue as an option:

| Finding | Option | Notes |
|---------|--------|-------|
| Wrong naming convention | Rename file-name.md (Recommended) | `mv` + update references |
| Skipped heading level | Fix heading hierarchy (Recommended) | Auto-fix h1→h3 gaps |
| Missing blank lines | Fix markdown formatting (Recommended) | Auto-fix spacing |
| File in wrong location | Move to docs/ (Recommended) | `mv` + update references |
| Missing code block language | [Flag only] | Needs manual language choice |
| Duplicate content | [Flag only] | Needs manual merge decision |
| Missing standard file | [Flag only] | Use `/a-star-is-born` for scaffolding |

## Phase 4: Execute

For approved actions:

**Renames**: `git mv` to preserve history, then grep + replace all references.

**Moves**: `git mv` to new location, update any relative links in other docs.

**Heading fixes**: Edit files to fix hierarchy (insert missing levels, don't demote everything).

**Markdown formatting**: Fix blank lines, list markers, trailing whitespace.

After all changes, run a quick verification:
- Check that no markdown links are broken
- Confirm renamed/moved files are tracked by git

## Final Summary

```
Papers shuffled.

  Scanned:     14 markdown files
  Renamed:     2 files (kebab-case)
  Moved:       1 file (to docs/)
  Fixed:       3 files (heading hierarchy, formatting)
  Flagged:     2 issues (need manual review)

Documentation is tidier.
```

## What It Doesn't Do

- No content writing — it organizes, not generates
- No content deletion — it moves and renames, not removes
- No cross-repo scanning — operates on current project only
- No template generation — that's `/a-star-is-born`

## Guidelines

- **Read-before-write** — scan everything before proposing changes
- **One interaction** — the multiselect is the only prompt
- **Preserve git history** — always use `git mv` for renames/moves
- **Update references** — after any rename/move, grep for old paths and update them
- **Conservative** — only auto-fix clear violations. Flag ambiguous cases
- **Respect intent** — if a file's location seems intentional (e.g., root-level guide for a framework), don't force it into docs/
