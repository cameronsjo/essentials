---
name: a-star-is-born
description: >
  Scaffold a new project from scratch. Beads, CONTRIBUTING, SECURITY, release-please,
  GitHub Actions, Claude Code config, docs structure, and AI tool symlinks.
category: workflow
---

# A Star Is Born

Scaffold a new project with all the standard tooling. One command, clean slate to production-ready.

**Announce at start:** "I'm using the a-star-is-born skill to scaffold this project."

## When to Use

- Starting a brand new project
- User says "new project," "scaffold," "init," "a star is born"
- User invokes `/a-star-is-born`

## Phase 1: Gather Requirements

Use `AskUserQuestion` to collect project details. Two questions max.

**Question 1: Project basics**

Ask for project name and language/framework. Options:
- TypeScript (Node)
- Python (uv)
- Go
- Other (free text)

**Question 2: Features** (multiselect)

All marked "(Recommended)" by default:
- Beads issue tracking (Recommended)
- CONTRIBUTING.md (Recommended)
- SECURITY.md (Recommended)
- Release Please + GitHub Actions (Recommended)
- Claude Code config (CLAUDE.md) (Recommended)
- AI tool symlinks (Recommended)
- docs/ structure (Recommended)
- LICENSE (MIT) (Recommended)

## Phase 2: Scaffold

Execute selected features. Order matters — git init first, then build on it.

### Core (always)

```bash
mkdir -p <project-name>
cd <project-name>
git init -b main
```

Create:
- `README.md` — project name, one-line description, "## Getting Started" placeholder
- `.gitignore` — language-appropriate (use GitHub's templates via `gh api`)
- `CHANGELOG.md` — empty with `# Changelog` header

### Beads (if selected)

```bash
bd init
```

### CONTRIBUTING.md (if selected)

Generate from the user's established pattern:
- Code of Conduct reference
- Getting Started (fork, clone, setup)
- Development Setup (language-specific)
- Commit format (Conventional Commits)
- PR guidelines

### SECURITY.md (if selected)

Generate from the user's established pattern:
- Supported Versions table
- Reporting a Vulnerability (GitHub private advisory)
- Response Timeline (48h initial, 7d status, 30d fix)
- Disclosure Policy

### Release Please (if selected)

Create `release-please-config.json`:

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "packages": {
    ".": {
      "release-type": "<node|python|go>",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": true,
      "changelog-path": "CHANGELOG.md"
    }
  }
}
```

Create `.release-please-manifest.json`:

```json
{
  ".": "0.1.0"
}
```

Create `.github/workflows/release-please.yml`:

```yaml
name: Release Please

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          config-file: release-please-config.json
          manifest-file: .release-please-manifest.json
```

Create `.github/workflows/ci.yml` — language-appropriate test + build workflow.

### Claude Code Config (if selected)

Create `CLAUDE.md` with:
- Project name and description
- Language/framework
- Key commands (build, test, lint)
- Project structure placeholder

### AI Tool Symlinks (if selected)

CLAUDE.md is the source of truth. Create symlinks for other tools:

```bash
# GitHub Copilot
mkdir -p .github
ln -s ../CLAUDE.md .github/copilot-instructions.md

# Cursor (legacy format)
ln -s CLAUDE.md .cursorrules

# Windsurf
ln -s CLAUDE.md .windsurfrules

# AGENTS.md standard
ln -s CLAUDE.md AGENTS.md

# Aider
ln -s CLAUDE.md CONVENTIONS.md
```

Add symlink targets to `.gitignore` comment block so intent is clear:

```gitignore
# AI tool symlinks (source of truth: CLAUDE.md)
# These are symlinks, committed intentionally
```

### Docs Structure (if selected)

```bash
mkdir -p docs/adr
```

Create `docs/adr/0001-initial-architecture.md` with ADR template:
- Status: Proposed
- Context, Decision, Consequences sections

### LICENSE (if selected)

MIT license with current year and user's name.

## Phase 3: Language-Specific Setup

### TypeScript (Node)

```bash
npm init -y
```

Update `package.json` with project name, description, `"type": "module"`.

### Python (uv)

```bash
uv init
```

### Go

```bash
go mod init github.com/cameronsjo/<project-name>
```

## Phase 4: Initial Commit + GitHub

```bash
git add -A
git commit -m "feat: initial project scaffold"
```

Ask via `AskUserQuestion`:
- "Create GitHub repo?" — Public (Recommended) / Private / Skip

If yes:

```bash
gh repo create cameronsjo/<project-name> --<visibility> --description "<description>" --source . --push
```

## Final Summary

```
A star is born.

  Project:     <name>
  Language:    <language>
  Features:    beads, contributing, security, release-please, claude, ai-symlinks, docs, license
  GitHub:      https://github.com/cameronsjo/<name>

Next steps:
  - Fill in CLAUDE.md with project-specific instructions
  - Add first ADR in docs/adr/
  - Start building
```

## Guidelines

- **Ask twice, execute once** — two AskUserQuestion interactions total (basics + features, then GitHub)
- **Sensible defaults** — everything recommended, user deselects what they don't want
- **Language-aware** — .gitignore, CI workflow, and setup commands match the chosen language
- **Symlinks, not copies** — AI tool configs point back to CLAUDE.md
- **Don't over-generate** — README gets a placeholder, not a novel. CLAUDE.md gets structure, not speculation
