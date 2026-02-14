---
name: field-notes
description: >
  Capture or review structured insights and gotchas from the current session.
  Two modes: capture (default) proposes entries, review grades existing entries.
category: workflow
---

# Field Notes

Structured capture and review of insights and gotchas for auto memory.

**Announce at start:** "I'm using the field-notes skill to [capture insights from this session / review existing memory entries]."

## Mode Selection

- `capture` (default): Propose new insights/gotchas from the current session
- `review`: Grade and prune existing memory entries

---

## Capture Mode

### 1. Load Conventions

Read both convention docs for format reference:

- `docs/insights.md` — format, categories, threshold, anti-patterns
- `docs/gotchas.md` — format, severity, staleness rules, anti-patterns

### 2. Read Current Memory

Read the project's auto memory files to understand what's already captured:

- `MEMORY.md` in the project memory directory
- Any topic files (`insights.md`, `gotchas.md`, etc.) in the same directory

### 3. Propose Entries

Scan the session for candidates. Primary sources:

- **`★ Insight` blocks** — these have already been deemed noteworthy during the session. Treat them as pre-formatted candidates; distill to the convention format
- **Debugging detours** — root causes, misleading errors, unexpected behavior
- **Process friction** — sequencing requirements, tool quirks, config surprises

Apply the threshold:

- **Insights**: Would this save 15 minutes if known at session start?
- **Gotchas**: Did this cost time? Could it bite again? Include the fix/mitigation if known

Filter out:

- Anything already captured in memory or CLAUDE.md
- Session-specific context that won't generalize
- Vague observations without actionable detail

### 4. Present for Approval

Use `AskUserQuestion` with **multiselect**. One interaction, one decision.

Format each option:

- Label: `[category] Short description` (insights) or `[severity] Short description` (gotchas)
- Description: The full formatted entry as it would appear in memory
- Strongest proposals marked "(Recommended)" and listed first

The user can approve, reject individually, or add their own via "Other."

### 5. Write Approved Entries

Determine where to write:

- **MEMORY.md under 180 lines**: Append to the appropriate section in MEMORY.md
  - Create section headers (`## Insights`, `## Gotchas`) if they don't exist
- **MEMORY.md at 180+ lines**: Write to topic files instead
  - `insights.md` in the memory directory for insights
  - `gotchas.md` in the memory directory for gotchas
  - Create the topic files if they don't exist
  - Add "See Also" entries in MEMORY.md pointing to the new files

Use the convention doc formats exactly. Include category/severity tags and date suffixes.

---

## Review Mode

### 1. Load All Memory

Read every file in the project memory directory:

- `MEMORY.md`
- All topic files (`insights.md`, `gotchas.md`, etc.)

### 2. Grade Entries

For each insight or gotcha entry (identifiable by `[category]` or `[severity]` tags):

- **Still relevant?** — Is the project/tool/pattern still active?
- **Ever triggered?** — Has this knowledge saved time since capture?
- **Duplicated?** — Same knowledge already in CLAUDE.md or another memory file?
- **Stale?** — Date older than 90 days without revalidation?

### 3. Present for Decision

Use `AskUserQuestion` with **multiselect**. One interaction.

For each entry that warrants review (30+ days old, potentially stale, or duplicated):

| Option | When |
|---|---|
| Keep | Still valuable, no action needed |
| Prune | Stale, redundant, or never triggered |
| Promote to CLAUDE.md | Important enough to be in every session's instructions |
| Move to topic file | Valuable but taking MEMORY.md space |

Mark obvious prune candidates with description explaining why.

### 4. Execute Changes

- **Prune**: Remove entry from its file
- **Promote**: Add to appropriate section in CLAUDE.md, remove from memory file
- **Move**: Transfer from MEMORY.md to the appropriate topic file
- **Keep**: No action

Report what changed: entries pruned, promoted, moved, and kept.

---

## Guidelines

- **One interaction per mode** — the multiselect is the only prompt
- **15-minute threshold** — if it wouldn't save 15 minutes, it's not worth the line
- **Keep MEMORY.md under 200 lines** — fan out to topic files is the pressure valve
- **Categorize, don't dump** — every entry gets a category or severity tag
- **Date everything** — `(YYYY-MM-DD)` suffix for recency tracking
- **Convention docs are reference** — read them, follow the formats, don't improvise
