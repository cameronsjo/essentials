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
```markdown
## Workflow: OpenSpec + Beads

- **OpenSpec** owns planning: `/opsx:new` → proposal → specs → design → tasks
- **Beads** owns execution: `bd create` from tasks → `bd ready` → implement → `bd update`
- Run `/opsx:verify` before archiving to catch spec drift
- See `openspec/AGENTS.md` for full OpenSpec workflow reference
```

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
