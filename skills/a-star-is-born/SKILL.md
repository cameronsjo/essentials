---
name: a-star-is-born
description: >
  Scaffold a new project or retrofit an existing one. Beads, OpenSpec, AGENTS.md, Makefile,
  release-please (disabled), CI, Biome/Ruff, Husky, AI symlinks, docs structure.
category: workflow
---

# A Star Is Born

Scaffold a new project or retrofit an existing one with standard tooling. Re-entrant — safe to run on projects that already have some pieces in place.

**Announce at start:** "I'm using the a-star-is-born skill to scaffold this project."

**Before scaffolding:** Read `templates.md` in this skill directory for all code templates and config files.

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
3. **Existing components** — check for each: `AGENTS.md`, `CLAUDE.md` (file vs symlink), `.beads/`, `openspec/`, `Makefile`, `biome.json`, `ruff.toml`, `.golangci.yml`, `.husky/`, `release-please-config.json`, `CONTRIBUTING.md`, `SECURITY.md`, `LICENSE`, `.github/workflows/ci.yml`, `docs/adr/`

Classify: **new repo** (no `.git` or no commits) vs **existing repo** (has commits).

### New Repo Questions

Project name comes from the command argument or conversation context. If unclear, ask.

Use `AskUserQuestion` — one call, four questions:

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

**Question 4** (header: "Husky", single select):
Set up Husky for git hooks (lint-staged on pre-commit)?
- Yes — install Husky + lint-staged (Recommended for team repos)
- Skip — solo project, I'll manage hooks myself

Then scaffold everything selected. The scaffold is opinionated by default — OpenSpec and Husky are the only opt-out questions. If the user wants to skip other components, they say so upfront or delete them after.

### Existing Repo Questions

Display a summary of what was detected vs what's missing:

```
Detected:
  Language:    TypeScript (package.json)
  AGENTS.md:   missing
  Beads:       missing
  OpenSpec:    missing
  Makefile:    missing
  Linting:     .eslintrc found (Biome recommended)
  ...
```

Use `AskUserQuestion` — one call, one question:

**Question 1** (header: "Scope", single select):
How should I apply the missing components?
- Apply all missing components (Recommended)
- Let me choose which to add
- Cancel

If "Let me choose" → second `AskUserQuestion` with **multiSelect** of only the missing components. Options vary by detection, drawn from: AGENTS.md + symlinks, Beads, OpenSpec, Makefile, Modern linting, Husky + lint-staged, Release-please, CI workflow, CONTRIBUTING, SECURITY, LICENSE, Docs structure.

**Non-destructive rules:**
- Never overwrite existing files unless explicitly asked
- If `CLAUDE.md` exists as a regular file (not symlink), migrate its content into `AGENTS.md` and replace `CLAUDE.md` with a symlink
- If legacy lint tools exist (ESLint, Prettier, flake8), note them but don't delete — let the user migrate

## Phase 2: Scaffold

For new repos, run everything in order. For existing repos, skip components that already exist (or were deselected). All templates and config examples are in `templates.md`.

### Core (new repos only)

```bash
mkdir -p <project-name>
cd <project-name>
git init -b main
```

Create: `README.md` (name + description + Getting Started), `.gitignore` (language-appropriate via `gh api`), `CHANGELOG.md` (empty with header).

### Beads

```bash
bd init
```

### OpenSpec (if selected)

**Skip if the user opted out.**

```bash
which openspec || npm install -g @fission-ai/openspec@latest
openspec init --tools claude
```

After init, add Beads integration to `openspec/config.yaml` — see `templates.md` for the config block.

### AGENTS.md — Primary AI Config

Create `AGENTS.md` as the **primary** AI instruction file with:
- Project name and description
- Language/framework and key commands (build, test, lint, format)
- Project structure
- If OpenSpec was initialized, include the workflow section (see `templates.md`)

### AI Tool Symlinks

AGENTS.md is the source of truth. Create symlinks for all major AI coding tools — see `templates.md` for the full list. For existing repos, use `ln -sf` for stale symlinks. Skip targets that exist as regular files — warn the user.

### Modern Tooling

Use the modern toolkit. **Only install if no equivalent exists.** See `templates.md` for install commands and config files.

- **TypeScript** → Biome (replaces ESLint + Prettier)
- **Python** → Ruff (replaces flake8, black, isort)
- **Go** → golangci-lint
- **Other** → skip automated setup; note in summary to configure manually

### Husky + lint-staged (if selected)

**Skip if the user opted out.** See `templates.md` for install commands and language-specific `.lintstagedrc.json` configs.

### Makefile

Create `Makefile` with `help` as default target. Language-appropriate targets for `dev`, `build`, `check`, `fix`, `test`. See `templates.md` for full templates per language. Adapt targets based on project needs.

### Release Please (Configured but Disabled)

Create config files ready to enable but **disabled by default** (`workflow_dispatch` only). See `templates.md` for all three files.

**Repo-level setting required:** After creating the GitHub repo (or on existing repos), enable "Allow GitHub Actions to create and approve pull requests" under Settings → Actions → General → Workflow permissions. Without this, release-please will fail even though the workflow YAML has `pull-requests: write`. Run:

```bash
gh api repos/{owner}/{repo}/actions/permissions/workflow -X PUT -f default_workflow_permissions=write -F can_approve_pull_request_reviews=true
```

### CI Workflow

Create `.github/workflows/ci.yml` — language-appropriate test, build, and lint workflow. Use `biome check` (TS), `ruff check` (Python), or `golangci-lint run` (Go) as the lint step.

For existing repos with a CI workflow: suggest adding the modern lint step if missing.

### CONTRIBUTING.md

Generate from conventions: Code of Conduct reference, Getting Started (fork, clone, setup), Development Setup, Commit format (Conventional Commits), PR guidelines.

### SECURITY.md

Generate from conventions: Supported Versions table, Reporting (GitHub private advisory), Response Timeline (48h/7d/30d), Disclosure Policy.

### Docs Structure

Create `docs/adr/` and `docs/adr/0001-initial-architecture.md` (ADR template).

### LICENSE

MIT license with current year and user's name.

### Language-Specific Setup (new repos only)

- **TypeScript:** `npm init -y`, set `"type": "module"`, install Biome
- **Python:** `uv init`, add Ruff
- **Go:** `go mod init github.com/<user>/<project-name>`, add golangci-lint config

## Phase 3: Commit + GitHub

### New repos

```bash
git add -A
git commit -m "feat: initial project scaffold"
```

If GitHub visibility was selected, generate a description first:

1. Read `README.md`, `package.json` / `pyproject.toml` / `go.mod` for context
2. Generate a concise description (max 350 chars): action-oriented, specific, includes key differentiators — no generic phrasing like "A tool for..."
3. Create the repo:

```bash
gh repo create <user>/<project-name> --<visibility> --description "<generated-description>" --source . --push
```

After repo creation, enable Actions PR permissions so release-please can create PRs:
```bash
gh api repos/<user>/<project-name>/actions/permissions/workflow -X PUT -f default_workflow_permissions=write -F can_approve_pull_request_reviews=true
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
  Makefile:    created
  Husky:       <initialized|skipped>
  OpenSpec:    <initialized|skipped>
  Beads:       initialized

  Added:       <list of components added>
  Skipped:     <list of components that already existed or opted out>

Next steps:
  - Fill in AGENTS.md with project-specific instructions
  - Enable release-please when you're ready for automated releases
    (also enable "Allow GitHub Actions to create and approve pull requests"
     in repo Settings → Actions → General → Workflow permissions)
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
- **Makefile as entry point** — every project gets a Makefile with help, check, fix, test targets
- **OpenSpec and Husky optional** — recommended but not forced; external dependencies get an opt-out
