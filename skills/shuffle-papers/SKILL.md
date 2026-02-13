---
name: shuffle-papers
description: >
  Sort, standardize, and triage documentation. Fix naming conventions, heading
  hierarchy, frontmatter consistency, and organizational structure.
category: workflow
---

# Shuffle Papers

Documentation housekeeping. Find the mess, sort it out, standardize what's drifted.

**Announce at start:** "I'm using the shuffle-papers skill to standardize documentation."

## When to Use

- Docs have grown organically and need organizing
- Naming conventions have drifted
- User says "shuffle papers," "organize docs," "triage documentation"
- User invokes `/shuffle-papers`

## Phase 1: Scan

Find all documentation files:

```bash
git ls-files '*.md'
```

Read each file's first 20 lines to capture frontmatter and title.

## Phase 2: Analyze

### Naming Conventions

| Location | Convention | Example |
|----------|-----------|---------|
| Root level | SCREAMING_SNAKE_CASE | `README.md`, `CONTRIBUTING.md` |
| Everywhere else | kebab-case | `getting-started.md`, `api-overview.md` |
| ADRs | Numeric prefix + kebab-case | `0001-initial-architecture.md` |

### Heading Hierarchy

- First heading should be `#` (h1)
- No skipped levels (`#` to `###` without `##`)
- One h1 per file

### Frontmatter Consistency

For files with YAML frontmatter: check field naming consistency across files.

### Structural Issues

- Files in wrong location (deep docs at root, ADRs outside `docs/adr/`)
- Missing standard files (README, CONTRIBUTING, CHANGELOG, LICENSE)
- Duplicate content across files

### Markdown Quality

- Blank lines around headings, lists, code blocks
- Consistent list markers (`-` preferred)
- Code blocks have language identifiers

## Phase 3: Present Findings

Group by severity: **Structural** > **Naming** > **Content**.

Use `AskUserQuestion` with **multiselect**:

| Finding | Option | Notes |
|---------|--------|-------|
| Wrong naming convention | Rename file-name.md (Recommended) | `git mv` + update references |
| Skipped heading level | Fix heading hierarchy (Recommended) | Auto-fix gaps |
| Missing blank lines | Fix markdown formatting (Recommended) | Auto-fix spacing |
| File in wrong location | Move to docs/ (Recommended) | `git mv` + update references |
| Missing code block language | [Flag only] | Needs manual language choice |
| Duplicate content | [Flag only] | Needs manual merge decision |

## Phase 4: Execute

**Renames/Moves**: `git mv` to preserve history, then grep + replace all references.

**Heading fixes**: Insert missing levels, don't demote everything.

**Markdown formatting**: Fix blank lines, list markers, trailing whitespace.

After all changes, verify no markdown links are broken.

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

## Guidelines

- **Read-before-write** — scan everything before proposing changes
- **One interaction** — the multiselect is the only prompt
- **Preserve git history** — always `git mv` for renames/moves
- **Update references** — after any rename/move, grep for old paths and fix them
- **Respect intent** — if a file's location seems intentional, don't force it into docs/
