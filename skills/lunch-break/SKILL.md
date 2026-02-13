---
name: lunch-break
description: >
  Mid-session memory save. Capture what we've figured out before it gets lost
  to compaction or context drift. Quick in, quick out.
category: workflow
---

# Lunch Break

Capture learnings mid-session so future-us doesn't re-discover what present-us already solved.

**Announce at start:** "I'm using the lunch-break skill to save session learnings."

## When to Use

- Context is getting long and compaction is coming
- You've just solved something gnarly and want to save the insight
- User says "lunch break," "save state," "let's capture this"
- User invokes `/lunch-break`

## What It Does

Two things. Fast.

### 1. Memory Save

If auto memory exists, use `AskUserQuestion` with **multiselect**. Claude proposes what it observed, user adds via "Other". Mark the strongest proposals with "(Recommended)".

Claude's proposals cover two angles:

**What went wrong** — gotchas, false starts, things that cost time:
- A dependency that behaved unexpectedly
- A config that works differently than documented
- An API that silently fails or has hidden constraints

**What we wish we knew at the start** — context that's obvious now but invisible cold:
- How a system actually works under the hood (vs how we assumed)
- Which approach worked (and which didn't, and why)
- Decisions made and the reasoning behind them

If Claude has nothing to propose, skip silently.

### 2. Quick Commit Check

Run `git status --short` on the **primary working directory only**.

If there are uncommitted changes, mention it: "You have N uncommitted files. Worth a commit before we keep going?"

If clean, say nothing.

## Guidelines

- **30 seconds, not 5 minutes** — this should feel like a breath, not a process
- **One interaction** — the multiselect is it
- **Skip empty** — if nothing worth saving, say "nothing to save" and move on
- **Keep MEMORY.md under 200 lines** — move overflow to topic files
