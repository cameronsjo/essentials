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

Project name comes from the command argument or conversation context. If unclear, ask.

Use `AskUserQuestion` — one call, two questions:

**Question 1: Language** (single select)
- TypeScript (Node)
- Python (uv)
- Go

**Question 2: GitHub visibility** (single select)
- Public (Recommended)
- Private
- Skip — no GitHub repo

Everything else is included by default. The scaffold is opinionated. If the user wants to skip a feature, they say so upfront or delete it after.

## Phase 2: Scaffold

Order matters — git init first, then build on it.

### Core

```bash
mkdir -p <project-name>
cd <project-name>
git init -b main
```

Create:
- `README.md` — project name, one-line description, `## Getting Started` placeholder
- `.gitignore` — language-appropriate (use GitHub's templates via `gh api`)
- `CHANGELOG.md` — empty with `# Changelog` header

### Beads

```bash
bd init
```

### CONTRIBUTING.md

Generate from the project's established conventions:
- Code of Conduct reference
- Getting Started (fork, clone, setup)
- Development Setup (language-specific prerequisites)
- Commit format (Conventional Commits)
- PR guidelines

### SECURITY.md

Generate from the project's established conventions:
- Supported Versions table
- Reporting a Vulnerability (GitHub private advisory)
- Response Timeline (48h initial, 7d status, 30d fix)
- Disclosure Policy

### Release Please

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

### Claude Code Config

Create `CLAUDE.md` with:
- Project name and description
- Language/framework and key commands (build, test, lint)
- Project structure

### AI Tool Symlinks

CLAUDE.md is the source of truth. Symlink for other tools:

```bash
mkdir -p .github
ln -s ../CLAUDE.md .github/copilot-instructions.md    # GitHub Copilot
ln -s CLAUDE.md .cursorrules                           # Cursor
ln -s CLAUDE.md .windsurfrules                         # Windsurf
ln -s CLAUDE.md AGENTS.md                              # Emerging standard
ln -s CLAUDE.md CONVENTIONS.md                         # Aider
```

### Docs Structure

```bash
mkdir -p docs/adr
```

Create `docs/adr/0001-initial-architecture.md` — ADR template with Status, Context, Decision, Consequences.

### LICENSE

MIT license with current year and user's name.

### Language-Specific Setup

**TypeScript:** `npm init -y`, set `"type": "module"` in package.json.

**Python:** `uv init`

**Go:** `go mod init github.com/<user>/<project-name>`

## Phase 3: Commit + GitHub

```bash
git add -A
git commit -m "feat: initial project scaffold"
```

If GitHub visibility was selected (not "Skip"):

```bash
gh repo create <user>/<project-name> --<visibility> --description "<description>" --source . --push
```

## Final Summary

```
A star is born.

  Project:     <name>
  Language:    <language>
  GitHub:      https://github.com/<user>/<name>

Next steps:
  - Fill in CLAUDE.md with project-specific instructions
  - Start building
```

## Guidelines

- **Opinionated by default** — include everything, skip nothing unless told
- **Two interactions max** — requirements gathering, then execution
- **Language-aware** — .gitignore, CI, setup commands all match the chosen language
- **Symlinks, not copies** — AI tool configs point back to CLAUDE.md
