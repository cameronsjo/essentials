# A Star Is Born — Templates

Reference templates for the scaffold. Read this file when generating project files.

## Biome (TypeScript)

Install:
```bash
npm install --save-dev --save-exact @biomejs/biome
npx @biomejs/biome init
```

Update `biome.json` (use the latest schema version):
```json
{
  "$schema": "https://biomejs.dev/schemas/<latest>/schema.json",
  "organizeImports": { "enabled": true },
  "linter": { "enabled": true, "rules": { "recommended": true } },
  "formatter": { "enabled": true, "indentStyle": "space", "indentWidth": 2 }
}
```

Add scripts to `package.json`:
```json
{ "scripts": { "check": "biome check .", "check:fix": "biome check --fix .", "format": "biome format --write ." } }
```

## Ruff (Python)

Install:
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

## golangci-lint (Go)

Create `.golangci.yml`:
```yaml
linters:
  enable: [errcheck, govet, staticcheck, unused, gosimple, ineffassign]
```

## Husky + lint-staged

Install:
```bash
npx husky init
npm install --save-dev lint-staged
```

`.lintstagedrc.json` by language:

**TypeScript:**
```json
{ "*.{ts,tsx,js,jsx,json,css,md}": ["biome check --fix"] }
```

**Python:**
```json
{ "*.py": ["ruff check --fix", "ruff format"] }
```

**Go:**
```json
{ "*.go": ["golangci-lint run --fix"] }
```

Update `.husky/pre-commit`:
```bash
npx lint-staged
```

## Makefile — TypeScript

```makefile
.DEFAULT_GOAL := help

## Development
.PHONY: dev
# Start development server
dev:
	npm run dev

.PHONY: build
# Build for production
build:
	npm run build

## Quality
.PHONY: check
# Run linting and format checks
check:
	npx biome check .

.PHONY: fix
# Auto-fix linting and formatting issues
fix:
	npx biome check --fix .

.PHONY: test
# Run test suite
test:
	npm test

## Help
.PHONY: help
# Show available targets
help:
	@grep -E '^[a-zA-Z_-]+:.*?#' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?# "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
```

## Makefile — Python

```makefile
.DEFAULT_GOAL := help

## Quality
.PHONY: check
# Run linting and format checks
check:
	uv run ruff check . && uv run ruff format --check .

.PHONY: fix
# Auto-fix linting and formatting issues
fix:
	uv run ruff check --fix . && uv run ruff format .

.PHONY: test
# Run test suite
test:
	uv run pytest

## Help
.PHONY: help
# Show available targets
help:
	@grep -E '^[a-zA-Z_-]+:.*?#' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?# "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
```

## Makefile — Go

```makefile
.DEFAULT_GOAL := help

## Development
.PHONY: build
# Build the binary
build:
	go build -o bin/ ./...

## Quality
.PHONY: check
# Run linting
check:
	golangci-lint run

.PHONY: test
# Run test suite
test:
	go test ./...

## Help
.PHONY: help
# Show available targets
help:
	@grep -E '^[a-zA-Z_-]+:.*?#' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?# "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
```

## Release Please

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

Create `.github/workflows/release-please.yml` (disabled by default):
```yaml
# Release Please — configured but disabled by default.
# To enable: replace on: block with: on: push: branches: [main]
# Also required: enable "Allow GitHub Actions to create and approve pull requests"
# in repo Settings → Actions → General → Workflow permissions.
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

## OpenSpec + Beads Config

Append to `openspec/config.yaml` after init:
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

AGENTS.md workflow section (if OpenSpec initialized):

````markdown
## OpenSpec Change Proposal Workflow

A spec-before-code gate for features that add or change behavior. Forces you to define what changes before writing how it changes. Three artifacts — proposal, spec deltas, task list — live in the repo alongside the code.

### When to Use

- New features or capabilities
- Breaking changes (API, schema, config)
- Architecture changes
- Performance/security work that changes behavior

### When to Skip

- Bug fixes restoring intended behavior
- Typos, formatting, comments
- Dependency updates (non-breaking)
- Config-only changes
- Tests for existing behavior

### Directory Structure

```
openspec/
├── project.md              # Project conventions
├── specs/                  # Current truth — what IS built
│   └── <capability>/
│       └── spec.md         # Requirements + scenarios
├── changes/                # Proposals — what SHOULD change
│   ├── <change-id>/
│   │   ├── proposal.md     # Why, what, impact, all consumers
│   │   ├── tasks.md        # Implementation checklist
│   │   ├── design.md       # Technical decisions (optional)
│   │   └── specs/          # Delta changes to existing specs
│   │       └── <capability>/
│   │           └── spec.md # ADDED/MODIFIED/REMOVED requirements
│   └── archive/            # Completed changes
```

### Workflow

1. Read existing specs → understand what's covered
2. Scaffold proposal → `proposal.md`, `tasks.md`, spec deltas
3. Validate → `openspec validate <id> --strict`
4. Get approval → review before coding
5. Implement → follow `tasks.md` in order
6. Check off tasks → update `tasks.md` when done
7. Archive after deploy → `openspec archive <id>` (merges deltas into main specs)

### Proposal Template

```markdown
# Change: <Brief description>

## Why
<1-2 sentences on problem/opportunity>

## What Changes
- <Bullet list of changes>
- <Mark breaking changes with **BREAKING**>

## Impact
- Affected specs: <list capabilities>
- Affected code: <key files/systems>
- All consumers: <grep for every file that reads/writes/passes
  the affected data — even ones that "already work">
```

### Spec Delta Format

Spec deltas use three sections: ADDED, MODIFIED, REMOVED. Every requirement MUST have at least one scenario.

```markdown
## ADDED Requirements

### Requirement: <Name>
The system SHALL <behavior>...

#### Scenario: <Name>
- **WHEN** <condition>
- **AND** <additional condition>
- **THEN** <expected outcome>

## MODIFIED Requirements

### Requirement: <Name>
<Full updated requirement text — not a partial diff>

#### Scenario: <Name>
- **WHEN** <condition>
- **THEN** <expected outcome>

## REMOVED Requirements

### Requirement: <Name>
Removed because: <reason>
```

### Consumer Parity

The pattern that causes bugs: prose says "applies to X and Y," but scenarios only cover X. Implementation follows scenarios, not prose.

Before writing spec deltas:

1. Grep for all consumers of the affected type/config/env var
2. List every consumer in the proposal's "All consumers" field
3. Write a scenario per consumer in the spec
4. Add a task per consumer in `tasks.md`

### Key Rules

- Every requirement MUST have at least one scenario — scenarios are the acceptance criteria
- Every consumer MUST have a scenario — if the requirement says "both daemon and CLI," both need scenarios
- Every consumer MUST have a task — untasked consumers don't get implemented
- MODIFIED requirements paste the full block — the archiver replaces the entire requirement, not a partial diff
- Change IDs are kebab-case, verb-led: `add-content-hash-sync`, `update-drift-detection`, `remove-legacy-hooks`

### CLI Commands

```
openspec list                     # Active changes
openspec list --specs             # Existing specifications
openspec show <item>              # View change or spec
openspec validate <id> --strict   # Validate before coding
openspec archive <id> --yes       # Archive after deploy
```

### Integration with Beads

- **OpenSpec** owns planning: proposal → specs → design → tasks
- **Beads** owns execution: `bd create` from tasks → `bd ready` → implement → `bd update`
- Run `openspec validate` before archiving to catch spec drift
````

## AI Tool Symlinks

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

For existing repos, use `ln -sf`. Skip targets that exist as regular files (non-symlink) — warn the user.
