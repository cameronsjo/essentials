---
name: field-report
description: >
  Write a detailed narrative of a significant session. Creates a reference doc
  in docs/field-reports/ and links it via beads for searchability.
category: workflow
---

# Field Report

Capture the full arc of a meaningful session as a project reference document.

**Announce at start:** "I'm using the field-report skill to write up what we accomplished this session."

## When to Use

- Session produced significant learnings, pipeline discoveries, or tooling comparisons
- User says "write this up," "document this," "this was worth capturing"
- User invokes `/field-report`
- End of a session where the work was more exploratory/experimental than code-shipping

**Not for:** routine feature work, simple bug fixes, or sessions where field-notes captures everything worth knowing. If the session's value fits in a one-liner insight, use `/field-notes` instead.

## Field Notes vs Field Reports

| | Field Notes | Field Report |
|---|---|---|
| **Granularity** | Atomic insight or gotcha | Full narrative arc |
| **Format** | One-liner with tags | Structured document with sections |
| **Lives in** | Auto memory | `docs/field-reports/` in the project repo |
| **Found via** | Memory auto-load | Beads search, grep, browsing |
| **Example** | "rembg handles VFX better than Vision" | Full pipeline: goal, tools tried, A/B comparison, recommendations |

## The Process

### 1. Propose Report Scope

Scan the session for what happened. Propose to the user:

- **Title**: Descriptive, specific (e.g., "Error Page Image Pipeline", "Auth Token Refresh Investigation")
- **Type**: What kind of session was this? (see Session Types below)
- **Key sections**: Which sections apply based on the type

Use `AskUserQuestion` — present the title and type as options, let user adjust via "Other."

### 2. Write the Document

Create `docs/field-reports/{slug}.md` in the project's working directory.

- Filename: kebab-case slug of the title
- Create the `docs/field-reports/` directory if it doesn't exist

#### Required Sections

Every report starts with:

```markdown
# {Title} — Field Report

**Date:** YYYY-MM-DD
**Type:** {type}
**Project:** {repo/project name}

## Goal

What we set out to do. One paragraph.
```

#### Type-Specific Sections

Pick from these based on the session type. Not all apply to every report.

| Section | When to include |
|---|---|
| `## Pipeline Overview` | Built a multi-step process or workflow |
| `## What We Tried` | Evaluated multiple approaches or tools |
| `## What Worked` | Approaches that succeeded (with details) |
| `## What Didn't Work` | Approaches that failed (with why) |
| `## Comparison` | A/B tested tools, approaches, or configurations |
| `## Root Cause` | Debugging session that found the underlying issue |
| `## Decisions Made` | Chose between options with rationale |
| `## Architecture` | Made structural/design decisions |
| `## Setup / Reproduction` | Steps to recreate the environment or result |
| `## Gotchas` | Things that surprised us or cost time |
| `## Recommendations` | What to do next time, default choices, flags |

#### Always End With

```markdown
## Key Takeaways

- Bullet list of 3-5 things future-us should know
- These should be actionable, not vague
```

### 3. Link via Beads

If beads is initialized (`.beads/` exists in the project):

```bash
bd create --title="{Title} — field report" --type=task --priority=4 \
  --description="Field report written to docs/field-reports/{slug}.md. {one-line summary of what was documented.}"
bd close {issue-id} --reason="Field report written to docs/field-reports/{slug}.md"
```

The beads issue is the **searchable index entry**. The document is the **detail**. Neither works alone.

If beads is not initialized, skip silently. The document stands on its own.

### 4. Report

```
Field report written.

  Doc:    docs/field-reports/{slug}.md
  Issue:  {issue-id} (closed)
  Type:   {type}

Search later: bd search "{keywords}"
```

## Session Types

| Type | Description | Key sections |
|---|---|---|
| `pipeline` | Built a multi-step process | Pipeline Overview, What Worked, What Didn't, Recommendations |
| `investigation` | Debugged or researched a problem | Root Cause, What We Tried, Gotchas |
| `evaluation` | Compared tools, libraries, or approaches | Comparison, What We Tried, Decisions Made, Recommendations |
| `architecture` | Made structural design decisions | Architecture, Decisions Made, Key Takeaways |
| `discovery` | Learned how a system works | Pipeline Overview, Gotchas, Setup / Reproduction |
| `spike` | Time-boxed exploration of feasibility | What We Tried, What Worked, What Didn't, Recommendations |

## Guidelines

- **Narrative, not bullet dump** — write it like you're explaining to future-you who has zero context
- **Specific over general** — include actual commands, config values, error messages, tool versions
- **Include the subjective** — "Vision looked cleaner on fur but lost hologram edges" is valuable context that doesn't survive as a field-note
- **Tables for comparisons** — when two things were A/B tested, a table with criteria is worth a thousand words
- **Don't duplicate field-notes** — if an insight was already captured in memory, reference it; don't rewrite it
- **One report per arc** — don't combine unrelated work into one report
- **Keep the filename searchable** — `error-page-image-pipeline.md` beats `session-2026-02-13.md`
