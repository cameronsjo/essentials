---
name: a-star-is-born
description: >
  Scaffold a new project or retrofit an existing one. Beads, OpenSpec, AGENTS.md,
  release-please (disabled), CI, Biome/Ruff, AI symlinks, docs structure.
category: workflow
---

# A Star Is Born

Scaffold a new project or retrofit an existing one with standard tooling. Re-entrant — safe to run on projects that already have some pieces in place.

**Announce at start:** "I'm using the a-star-is-born skill to scaffold this project."

## When to Use

- Starting a brand new project
- Retrofitting an existing project with missing essentials
- User says "new project," "scaffold," "init," "a star is born," "upgrade," "retrofit," "add essentials," "modernize"
- User invokes `/a-star-is-born`

## Phase 1: Detect & Ask

### Detection (silent, no user interaction)

Run these checks in parallel:

1. **Repo state** — does `.git` exist? Any commits? Is there a remote?
2. **Language** — check for `package.json` (TypeScript), `pyproject.toml` (Python), `go.mod` (Go)
3. **Existing components** — check for each: `AGENTS.md`, `CLAUDE.md` (file vs symlink), `.beads/`, `openspec/`, `biome.json`, `ruff.toml`, `.golangci.yml`, `release-please-config.json`, `CONTRIBUTING.md`, `SECURITY.md`, `LICENSE`, `.github/workflows/ci.yml`, `docs/adr/`

Classify: **new repo** (no `.git` or no commits) vs **existing repo** (has commits).

### New Repo Questions

Project name comes from the command argument or conversation context. If unclear, ask.

Use `AskUserQuestion` — one call, three questions:

**Question 1** (header: "Language", single select):
Which language?
- TypeScript (Recommended)
- Python
- Go

**Question 2** (header: "Visibility", single select):
GitHub visibility?
- Public (Recommended)
- Private
- Skip — no GitHub repo

**Question 3** (header: "OpenSpec", single select):
Initialize OpenSpec for spec-driven development?
- Yes — install and configure OpenSpec + Beads workflow (Recommended)
- Skip — I'll add it later

Then scaffold everything selected. The scaffold is opinionated by default — OpenSpec is the only opt-out question. If the user wants to skip other components, they say so upfront or delete them after.

### Existing Repo Questions

Display a summary of what was detected vs what's missing:

```
Detected:
  Language:    TypeScript (package.json)
  AGENTS.md:   missing
  Beads:       missing
  OpenSpec:    missing
  Linting:     .eslintrc found (Biome recommended)
  ...
```

Use `AskUserQuestion` — one call, one question:

**Question 1** (header: "Scope", single select):
How should I apply the missing components?
- Apply all missing components (Recommended)
- Let me choose which to add
- Cancel

If "Let me choose" → second `AskUserQuestion` with **multiSelect** of only the missing components. Options vary by detection, drawn from: AGENTS.md + symlinks, Beads, OpenSpec, Modern linting, Release-please, CI workflow, CONTRIBUTING, SECURITY, LICENSE, Docs structure.

**Non-destructive rules:**
- Never overwrite existing files unless explicitly asked
- If `CLAUDE.md` exists as a regular file (not symlink), migrate its content into `AGENTS.md` and replace `CLAUDE.md` with a symlink
- If legacy lint tools exist (ESLint, Prettier, flake8), note them but don't delete — let the user migrate

## Phase 2: Scaffold

For new repos, run everything in order. For existing repos, skip components that already exist (or were deselected).

### Core (new repos only)

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

### OpenSpec (if selected)

**Skip this section if the user opted out of OpenSpec.**

```bash
# Install if not available
which openspec || npm install -g @fission-ai/openspec@latest

# Initialize with Claude tooling
openspec init --tools claude
```

After init, add Beads integration to `openspec/config.yaml` — append to the `context` block:

```yaml
context: |
  This project uses Beads (bd) for task tracking and agent memory.
  After planning, convert tasks to Beads issues using `bd create`.
  Use `bd ready` to find the next available task.
  Always commit Beads changes alongside code changes.

rules:
  tasks:
    - Each top-level task should map to a Beads issue after creation
    - Include acceptance criteria for each task
```

### AGENTS.md — Primary AI Config

Create `AGENTS.md` as the **primary** AI instruction file with:
- Project name and description
- Language/framework and key commands (build, test, lint, format)
- Project structure

If OpenSpec was initialized, include the workflow section:

```markdown
## Workflow: OpenSpec + Beads

- **OpenSpec** owns planning: `/opsx:new` → proposal → specs → design → tasks
- **Beads** owns execution: `bd create` from tasks → `bd ready` → implement → `bd update`
- Run `/opsx:verify` before archiving to catch spec drift
- See `openspec/AGENTS.md` for full OpenSpec workflow reference
```

### AI Tool Symlinks

AGENTS.md is the source of truth. Symlink for every major AI coding tool:

```bash
mkdir -p .github
ln -s ../AGENTS.md .github/copilot-instructions.md    # GitHub Copilot
ln -s AGENTS.md CLAUDE.md                              # Claude Code
ln -s AGENTS.md .cursorrules                           # Cursor
ln -s AGENTS.md .windsurfrules                         # Windsurf
ln -s AGENTS.md .clinerules                            # Cline / Roo Code
ln -s AGENTS.md GEMINI.md                              # Gemini CLI
ln -s AGENTS.md CONVENTIONS.md                         # Aider
ln -s AGENTS.md .replit.md                             # Replit
```

For existing repos, use `ln -sf` to overwrite stale symlinks. Skip any target that exists as a regular file (non-symlink) — warn the user instead.

### Modern Tooling

Use the modern toolkit. **Only install if no equivalent exists.**

#### TypeScript

**Biome** for linting + formatting (replaces ESLint + Prettier):
```bash
npm install --save-dev --save-exact @biomejs/biome
npx @biomejs/biome init
```
Update `biome.json`:
```json
{
  "$schema": "https://biomejs.dev/schemas/2.0.0/schema.json",
  "organizeImports": { "enabled": true },
  "linter": { "enabled": true, "rules": { "recommended": true } },
  "formatter": { "enabled": true, "indentStyle": "space", "indentWidth": 2 }
}
```
Add scripts to `package.json`:
```json
{ "scripts": { "check": "biome check .", "check:fix": "biome check --fix .", "format": "biome format --write ." } }
```

#### Python

**Ruff** for linting + formatting (replaces flake8, black, isort):
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

**golangci-lint** — create `.golangci.yml`:
```yaml
linters:
  enable: [errcheck, govet, staticcheck, unused, gosimple, ineffassign]
```

### Release Please (Configured but Disabled)

Create config files so release-please is ready to enable, but **do not enable by default**.

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
{ ".": "0.1.0" }
```

Create `.github/workflows/release-please.yml` with `workflow_dispatch` only:
```yaml
# Release Please — configured but disabled by default.
# To enable, replace on: block with: on: push: branches: [main]
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

Create `.github/workflows/ci.yml` — language-appropriate test, build, and lint workflow. Use `biome check` (TS), `ruff check` (Python), or `golangci-lint run` (Go) as the lint step.

For existing repos with a CI workflow: suggest adding the modern lint step if missing.

### CONTRIBUTING.md

Generate from conventions: Code of Conduct reference, Getting Started (fork, clone, setup), Development Setup, Commit format (Conventional Commits), PR guidelines.

### SECURITY.md

Generate from conventions: Supported Versions table, Reporting (GitHub private advisory), Response Timeline (48h/7d/30d), Disclosure Policy.

### Docs Structure

```bash
mkdir -p docs/adr
```

Create `docs/adr/0001-initial-architecture.md` — ADR template with Status, Context, Decision, Consequences.

### LICENSE

MIT license with current year and user's name.

### Language-Specific Setup (new repos only)

**TypeScript:** `npm init -y`, set `"type": "module"`, install Biome.

**Python:** `uv init`, add Ruff.

**Go:** `go mod init github.com/<user>/<project-name>`, add golangci-lint config.

## Phase 3: Commit + GitHub

### New repos

```bash
git add -A
git commit -m "feat: initial project scaffold"
```

If GitHub visibility was selected:
```bash
gh repo create <user>/<project-name> --<visibility> --description "<description>" --source . --push
```

### Existing repos

```bash
git add -A
git commit -m "feat: apply essentials scaffold"
```

## Final Summary

```
A star is born.

  Project:     <name>
  Language:    <language>
  GitHub:      https://github.com/<user>/<name>
  Lint/Format: <biome|ruff|golangci-lint>
  OpenSpec:    <initialized|skipped>
  Beads:       initialized

  Added:       <list of components added>
  Skipped:     <list of components that already existed or opted out>

Next steps:
  - Fill in AGENTS.md with project-specific instructions
  - Enable release-please when you're ready for automated releases
  - Run /opsx:new to start your first change proposal (if OpenSpec initialized)
  - Start building
```

## Guidelines

- **Re-entrant** — safe to run on new or existing repos; skips what exists
- **Opinionated by default** — include everything, skip nothing unless told
- **Two interactions max** — detection + questions, then execution
- **Non-destructive** — never overwrite existing files; migrate gracefully
- **Language-aware** — .gitignore, CI, setup, and linting match the chosen language
- **Symlinks, not copies** — AI tool configs point back to AGENTS.md
- **Modern toolkit** — Biome over ESLint/Prettier, Ruff over flake8/black, golangci-lint for Go
- **Release-please ready, not running** — config files present, workflow disabled until opted in
- **OpenSpec optional** — recommended but not forced; only external dependency with an opt-out
