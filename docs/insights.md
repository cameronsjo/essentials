# Insight Capture Conventions

Convention reference for the `field-notes` skill. Defines what qualifies as an insight and how to write one.

## Threshold

**Would this save 15 minutes if known at session start?**

If the answer is no, it's not worth the line. Auto memory is finite. Treat every line like a seat on a lifeboat.

## Format

One-liner with context. Category tag, insight text, source/date suffix.

```
[category] Insight text — source (YYYY-MM-DD)
```

### Examples

```
[tooling] Cache keys on version field, not content hash — same version = stale cache even after changes — dependency debugging (2026-02-10)
[workflow] Remote registry fetches from origin, not local — must push before sync commands — release pipeline (2026-02-09)
[debugging] Terminal emulator drops ANSI sequences on Windows — run through WSL for clean rendering — environment setup (2026-01-28)
[architecture] Removing a parent config entry cascades deletes to child references — back up before restructuring — config management (2026-02-08)
[integration] Nested CLI invocations fail when parent session env var is set — unset before spawning — scripting (2026-02-09)
```

## Categories

| Category | When to use |
|---|---|
| `debugging` | Root causes, diagnostic techniques, misleading error messages |
| `architecture` | Design decisions, system boundaries, data flow patterns |
| `tooling` | Tool behavior, configuration quirks, version-specific behavior |
| `workflow` | Process improvements, sequencing requirements, automation patterns |
| `integration` | Cross-system interactions, API behavior, protocol details |

## Anti-Patterns

Do not capture:

- **Vague observations** — "X was slow" without specifics
- **Already-documented behavior** — if it's in CLAUDE.md or official docs, don't duplicate it
- **Session-specific context** — current task details, in-progress work, temporary state
- **Unverified conclusions** — one occurrence is not a pattern. Verify before writing
- **Implementation details** — "function X is on line 42" changes next commit
