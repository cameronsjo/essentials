# Gotcha Capture Conventions

Convention reference for the `field-notes` skill. Defines what qualifies as a gotcha and how to write one.

## Threshold

**Did this cost time? Could it bite again?**

If it wasted time once and the trigger condition still exists, write it down. Gotchas are the landmines in your codebase — mark them before someone else steps on them.

## Format

One-liner with trigger, consequence, and fix. Severity tag, gotcha text, date suffix.

```
[severity] Trigger condition → consequence. Fix: mitigation/workaround — (YYYY-MM-DD)
```

If no fix is known, use `Fix: none known` so it's explicitly marked as an open wound.

### Examples

```
[breaking] Removing a parent config entry cascades deletes to child references → features silently disabled. Fix: back up child references before restructuring — (2026-02-08)
[time-waster] Forked repos clone with main tracking upstream remote → pushes go to wrong remote. Fix: git push -u origin main after cloning — (2026-02-10)
[data-risk] Cache keys on version field, not content hash → same version serves stale content after changes. Fix: bump version + clear cache on update — (2026-02-10)
[time-waster] Orphaned hook references survive after removing their source → startup errors from missing scripts. Fix: audit config for leftover references after removal — (2026-02-11)
```

## Severity Levels

| Severity | Definition | Example |
|---|---|---|
| `breaking` | Stops work entirely. Requires immediate intervention | Authentication failure, missing dependency, corrupted state |
| `data-risk` | Potential for data loss or silent corruption | Stale cache serving wrong content, writes to wrong branch |
| `time-waster` | Costs minutes, not catastrophic | Wrong defaults, confusing error messages, undocumented prerequisites |

## Date-Tagging

Every gotcha gets a date suffix: `(YYYY-MM-DD)`

- Enables recency tracking during reviews
- Gotchas older than 90 days without revalidation are pruning candidates
- If you re-encounter a gotcha, update the date — it's still active

## Staleness Rules

During `/field-notes review`:

- **< 30 days**: Keep by default
- **30-90 days**: Review — still relevant?
- **> 90 days**: Pruning candidate unless confirmed still active
- **Resolved gotchas**: Prune immediately (e.g., bug was fixed upstream)

## Anti-Patterns

Do not capture:

- **Known limitations** — documented behavior is not a gotcha
- **One-time flukes** — if it can't happen again, it's an anecdote
- **Skill issues** — "I forgot to run X" is not a gotcha, it's a checklist item
- **Obvious things** — if every developer would expect this behavior, it's not surprising enough to note
