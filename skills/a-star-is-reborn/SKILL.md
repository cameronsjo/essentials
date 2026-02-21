---
name: a-star-is-reborn
description: >
  Apply the essentials scaffold to an existing repository. Adds AGENTS.md, Biome/Ruff/golangci-lint,
  release-please (configured but disabled), Beads, CONTRIBUTING, SECURITY, AI tool symlinks,
  and docs structure — without overwriting existing files.
category: workflow
---

# A Star Is Reborn

Retrofit an existing project with the essentials scaffold. Same opinionated tooling as `a-star-is-born`, but non-destructive — existing files are preserved.

**Announce at start:** "I'm using the a-star-is-reborn skill to upgrade this project with essentials."

## When to Use

- Applying the essentials scaffold to an **existing** repository
- User says "upgrade," "retrofit," "add essentials," "a star is reborn," or "modernize"
- User invokes `/a-star-is-reborn`

## Phase 1: Assess the Project

Read the existing project to understand what's already in place.

Run these checks (all in parallel where possible):

1. **Language detection** — check for `package.json` (TypeScript/Node), `pyproject.toml` / `setup.py` (Python), `go.mod` (Go)
2. **Existing config files** — check for `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.windsurfrules`, `CONVENTIONS.md`, `.github/copilot-instructions.md`
3. **Existing lint/format tools** — check for `.eslintrc*`, `.prettierrc*`, `biome.json`, `ruff.toml`, `.golangci.yml`
4. **Existing CI** — check for `.github/workflows/`
5. **Existing release-please** — check for `release-please-config.json`, `.release-please-manifest.json`
6. **Existing docs** — check for `CONTRIBUTING.md`, `SECURITY.md`, `LICENSE`, `docs/`
7. **Beads** — check for `.beads/`

Present a summary of what exists and what will be added. Use `AskUserQuestion` with one question:

**Question 1: Confirm changes** (single select)
- Apply all missing essentials (Recommended)
- Let me choose which pieces to add
- Cancel

If the user picks "Let me choose," present a multi-select with the missing components.

## Phase 2: Apply

For each component, **skip if it already exists** unless the user explicitly asks to overwrite.

### AGENTS.md — Primary AI Config

If `AGENTS.md` does not exist, create it with:
- Project name and description (infer from README, package.json, or pyproject.toml)
- Language/framework and key commands (build, test, lint, format)
- Project structure (based on actual directory layout)

If `CLAUDE.md` exists as a regular file (not a symlink), **migrate it**:
1. Copy its contents into the new `AGENTS.md`
2. Remove the old `CLAUDE.md`
3. Create `CLAUDE.md` as a symlink to `AGENTS.md`

### AI Tool Symlinks

AGENTS.md is the source of truth. Create symlinks for other tools (skip if target already exists as a non-symlink file):

```bash
mkdir -p .github
ln -sf ../AGENTS.md .github/copilot-instructions.md    # GitHub Copilot
ln -sf AGENTS.md .cursorrules                           # Cursor
ln -sf AGENTS.md .windsurfrules                         # Windsurf
ln -sf AGENTS.md CLAUDE.md                              # Claude Code
ln -sf AGENTS.md CONVENTIONS.md                         # Aider
```

### Modern Tooling (Biome & Friends)

Detect the project language and install the modern toolkit if no equivalent is present.

#### TypeScript (if no `biome.json` exists)

- **Biome** for linting + formatting
  ```bash
  npm install --save-dev --save-exact @biomejs/biome
  npx @biomejs/biome init
  ```
  Update `biome.json`:
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
- Add scripts to `package.json` (merge, don't overwrite existing scripts):
  ```json
  {
    "scripts": {
      "check": "biome check .",
      "check:fix": "biome check --fix .",
      "format": "biome format --write ."
    }
  }
  ```
- If `.eslintrc*` or `.prettierrc*` exist, inform the user that Biome replaces them but **do not delete** — let the user migrate at their pace.

#### Python (if no `ruff.toml` exists)

- **Ruff** for linting + formatting
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

#### Go (if no `.golangci.yml` exists)

- **golangci-lint** config
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

### Release Please (Configured but Disabled)

If no `release-please-config.json` exists, create the config files with the workflow **disabled** (same as `a-star-is-born`):

- `release-please-config.json`
- `.release-please-manifest.json`
- `.github/workflows/release-please.yml` (with `on: workflow_dispatch` only)

### CI Workflow

If no `.github/workflows/ci.yml` exists, create a language-appropriate CI workflow. Incorporate `biome check` (TS), `ruff check` (Python), or `golangci-lint run` (Go) as the lint step.

If a CI workflow already exists, suggest adding the modern lint step if it's missing.

### Beads

If `.beads/` does not exist:
```bash
bd init
```

### CONTRIBUTING.md

If not present, generate from the project's conventions (same as `a-star-is-born`).

### SECURITY.md

If not present, generate from the project's conventions (same as `a-star-is-born`).

### Docs Structure

If `docs/adr/` does not exist:
```bash
mkdir -p docs/adr
```

Create `docs/adr/0001-initial-architecture.md` if not present.

### LICENSE

If not present, create MIT license with current year and user's name.

## Phase 3: Commit

Stage and commit the changes:

```bash
git add -A
git commit -m "feat: apply essentials scaffold to existing project"
```

## Final Summary

```
A star is reborn.

  Project:     <name>
  Language:    <language>
  Added:       <list of components added>
  Skipped:     <list of components that already existed>
  Lint/Format: <biome|ruff|golangci-lint>

Next steps:
  - Review AGENTS.md and tailor to your project
  - Enable release-please when you're ready for automated releases
  - Run `<lint-command>` to check for issues
```

## Guidelines

- **Non-destructive** — never overwrite existing files unless explicitly asked
- **Detect, don't assume** — inspect the project before making changes
- **Migrate gracefully** — if CLAUDE.md exists, fold it into AGENTS.md
- **Modern toolkit** — Biome over ESLint/Prettier, Ruff over flake8/black, golangci-lint for Go
- **Inform, don't force** — if legacy tools exist (ESLint, Prettier, flake8), note them but don't delete
- **Symlinks, not copies** — AI tool configs point back to AGENTS.md
- **Release-please ready, not running** — config files present, workflow disabled until opted in
