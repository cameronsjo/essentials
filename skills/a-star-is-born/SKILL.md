---
name: a-star-is-born
description: >
  Scaffold a new project from scratch. Beads, CONTRIBUTING, SECURITY, release-please (configured but disabled),
  GitHub Actions CI, AGENTS.md config, Biome, docs structure, and AI tool symlinks.
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

### Release Please (Configured but Disabled)

Create the config files so release-please is ready to enable, but **do not enable the workflow by default**.

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

Create `.github/workflows/release-please.yml` with the workflow **disabled** (`on: workflow_dispatch` only, no push trigger):

```yaml
# Release Please — configured but disabled by default.
# To enable automatic releases on push to main, replace the `on:` block with:
#
#   on:
#     push:
#       branches: [main]
#
name: Release Please

on:
  workflow_dispatch: {}

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

### CI Workflow

Create `.github/workflows/ci.yml` — language-appropriate test, build, and lint workflow. For TypeScript projects, use `biome check` as the lint step.

### Modern Tooling (Biome & Friends)

Use the modern 2025/2026 developer toolkit. **Language-specific defaults below.**

#### TypeScript

- **Biome** for linting + formatting (replaces ESLint + Prettier)
  ```bash
  npm install --save-dev --save-exact @biomejs/biome
  npx @biomejs/biome init
  ```
  Then update the generated `biome.json` to use the recommended preset:
  ```json
  {
    "$schema": "https://biomejs.dev/schemas/2.0.0/schema.json",
    "organizeImports": {
      "enabled": true
    },
    "linter": {
      "enabled": true,
      "rules": {
        "recommended": true
      }
    },
    "formatter": {
      "enabled": true,
      "indentStyle": "space",
      "indentWidth": 2
    }
  }
  ```
- Add scripts to `package.json`:
  ```json
  {
    "scripts": {
      "check": "biome check .",
      "check:fix": "biome check --fix .",
      "format": "biome format --write ."
    }
  }
  ```

#### Python

- **Ruff** for linting + formatting (replaces flake8, black, isort)
  ```bash
  uv add --dev ruff
  ```
  Create `ruff.toml`:
  ```toml
  target-version = "py312"
  line-length = 88

  [lint]
  select = ["E", "F", "I", "N", "UP", "RUF"]

  [format]
  quote-style = "double"
  ```

#### Go

- **golangci-lint** for comprehensive linting
  ```bash
  # CI installs via action; local install is optional
  ```
  Create `.golangci.yml`:
  ```yaml
  linters:
    enable:
      - errcheck
      - govet
      - staticcheck
      - unused
      - gosimple
      - ineffassign
  ```

### AGENTS.md — Primary AI Config

Create `AGENTS.md` as the **primary** AI instruction file with:
- Project name and description
- Language/framework and key commands (build, test, lint, format)
- Project structure

### AI Tool Symlinks

AGENTS.md is the source of truth. Symlink for other tools:

```bash
mkdir -p .github
ln -s ../AGENTS.md .github/copilot-instructions.md    # GitHub Copilot
ln -s AGENTS.md .cursorrules                           # Cursor
ln -s AGENTS.md .windsurfrules                         # Windsurf
ln -s AGENTS.md CLAUDE.md                              # Claude Code
ln -s AGENTS.md CONVENTIONS.md                         # Aider
```

### Docs Structure

```bash
mkdir -p docs/adr
```

Create `docs/adr/0001-initial-architecture.md` — ADR template with Status, Context, Decision, Consequences.

### LICENSE

MIT license with current year and user's name.

### Language-Specific Setup

**TypeScript:** `npm init -y`, set `"type": "module"` in package.json, install Biome (see Modern Tooling above).

**Python:** `uv init`, add Ruff (see Modern Tooling above).

**Go:** `go mod init github.com/<user>/<project-name>`, add golangci-lint config (see Modern Tooling above).

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
  Lint/Format: <biome|ruff|golangci-lint>

Next steps:
  - Fill in AGENTS.md with project-specific instructions
  - Enable release-please when you're ready for automated releases
  - Start building
```

## Guidelines

- **Opinionated by default** — include everything, skip nothing unless told
- **Two interactions max** — requirements gathering, then execution
- **Language-aware** — .gitignore, CI, setup commands, and linting all match the chosen language
- **Symlinks, not copies** — AI tool configs point back to AGENTS.md
- **Modern toolkit** — Biome over ESLint/Prettier, Ruff over flake8/black, golangci-lint for Go
- **Release-please ready, not running** — config files present, workflow disabled until opted in
