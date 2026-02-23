---
name: github-issue
description: >
  This skill should be used when the user asks to "write an issue", "give me a GitHub issue",
  "file an issue for this", "write that up as an issue", or wants to distill an investigation
  or conversation into a structured GitHub issue they can copy-paste or create via gh CLI.
category: workflow
---

# GitHub Issue

Distill conversation context into a structured GitHub issue: what's wrong, how it was diagnosed, and what would fix it.

**Announce at start:** "I'm using the github-issue skill to distill this into a GitHub issue."

## When to Use

- Mid-session investigation surfaced a bug, feature request, or improvement
- User says "give me a GitHub issue", "write that up", "file an issue for this"
- User invokes `/github-issue`
- A problem was diagnosed but the fix belongs in a different repo or session

## The Process

### 1. Scan the Session

Review the conversation for:

- **The problem**: What went wrong or what's missing
- **The diagnosis**: How it was discovered, what was checked, evidence gathered
- **The root cause**: Why it's happening (if known)
- **The fix**: What would resolve it, at what level of confidence

If the session lacks sufficient context, ask the user to fill gaps before drafting.

### 2. Determine the Target

Identify which repo this issue belongs in. Sources of truth:

- Explicit user statement ("file this on bosun")
- Inferred from context (Bosun alert dedup -> bosun repo)
- Ask if ambiguous

### 3. Draft the Issue

Generate a markdown block the user can copy-paste. Structure:

```markdown
## Title

<!-- Short, specific. Convention: "type: description" e.g. "feat: alert dedup for drift notifications" -->

## Problem

<!-- 2-4 sentences. What's happening, what's the impact. Include frequency/severity if known. -->

## Diagnosis

<!-- How this was discovered. Key evidence: log lines, commands run, timestamps.
     Keep it concise — enough for someone else to reproduce or verify. -->

## Root Cause

<!-- Why it's happening. If uncertain, say so and list hypotheses. -->

## Suggested Fix

<!-- Concrete approach. Include config sketches, pseudocode, or API references if helpful.
     Flag confidence level: "confirmed fix" vs "likely approach" vs "needs investigation". -->

## Labels

<!-- Comma-separated: bug, enhancement, alerting, infra, etc. -->
```

### 4. Present Options

After rendering the markdown block, ask the user:

| Option | Action |
|---|---|
| Copy-paste | Output is already in the message — done |
| Create via gh | Run `gh issue create` with the content |
| Edit first | User modifies, then create |

If creating via `gh`:

```bash
gh issue create --repo owner/repo --title "title" --body "$(cat <<'EOF'
...issue body...
EOF
)"
```

Add labels with `--label` flags if the repo has them configured.

## Style Guide

- **Be specific over comprehensive** — a tight 10-line issue beats a sprawling 50-line one
- **Include evidence** — log snippets, commands, timestamps. Not "it was broken" but "healthcheck returned `Stale file handle` with 147-failure streak"
- **Separate diagnosis from fix** — the person reading may agree on the problem but have a different solution
- **Flag uncertainty** — "likely cause" and "suggested approach" are fine. Don't present guesses as facts
- **Match the repo's conventions** — if the target repo uses specific issue templates or label taxonomies, follow them

## Guidelines

- **One issue per problem** — split compound issues into separate filings
- **Link related context** — reference other issues, PRs, or docs if relevant
- **Skip the issue if it's trivial** — if the fix is a one-liner you're about to commit, just commit it
- **Conversation context is the input** — the skill synthesizes from what's already been discussed, not from scratch
