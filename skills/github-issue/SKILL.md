---
name: github-issue
description: >
  This skill should be used when the user asks to "write an issue", "give me a GitHub issue",
  "file an issue for this", "write that up as an issue", or wants to distill an investigation
  or conversation into a structured GitHub issue they can copy-paste or create via gh CLI.
  Handles both owned repos (direct creation) and external repos (template-aware script generation).
license: MIT
metadata:
  author: cameronsjo
  version: "1.0"
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

Then determine ownership:

```bash
gh api "repos/OWNER/REPO" --jq '.permissions.push // false'
```

- **`true`** = Owned repo. Use the **Direct Creation** path (Step 3a)
- **`false`** = External repo. Use the **External Repo** path (Step 3b)

If `gh` is blocked by git-guardrails for the target repo, that also confirms external.

### 3a. Draft the Issue (Owned Repo)

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

Then present options:

| Option | Action |
|---|---|
| Copy-paste | Output is already in the message — done |
| Create via gh | Run `gh issue create` with the content |
| Edit first | User modifies, then create |

If creating via `gh`:

```bash
gh issue create --repo owner/repo --title "title" --body-file /tmp/issue-body.md
```

Add labels with `--label` flags if the repo has them configured.

### 3b. Draft the Issue (External Repo)

External repos require the user to run the `gh` command themselves (git-guardrails blocks writes to unowned repos). Follow this workflow:

#### Look Up Issue Templates

Check if the target repo has issue templates:

```bash
gh api "repos/OWNER/REPO/contents/.github/ISSUE_TEMPLATE" --jq '.[].name'
```

If templates exist, read the relevant one (usually `feature_request.yml` or `bug_report.yml`):

```bash
gh api "repos/OWNER/REPO/contents/.github/ISSUE_TEMPLATE/feature_request.yml" --jq '.content' | base64 -d
```

#### Formulate the Body

- **If a template exists**: Map session context to the template's fields. YAML `type: textarea` blocks become markdown `### {label}` sections. Respect `required` fields
- **If no template**: Use the standard structure from Step 3a

#### Write the Body File

Write the issue body to a temp file. This avoids shell quoting issues (apostrophes, backticks, JSON in markdown all break HEREDOC patterns):

```bash
# Write to: /tmp/{repo-name}-issue-body.md
```

**MUST** use the Write tool, not HEREDOC or echo — markdown with code blocks, tables, and special characters is fragile in shell strings.

#### Generate the Script

Write a minimal shell script the user can execute:

```bash
#!/usr/bin/env bash
gh issue create --repo OWNER/REPO \
  --title "issue title" \
  --body-file /tmp/{repo-name}-issue-body.md
```

**MUST** use `--body-file` instead of `--body` with HEREDOC. This is the key lesson — inline body strings break on:

- Smart quotes and apostrophes (`There's`, `don't`)
- Backtick-fenced code blocks inside the body
- JSON examples with nested quotes
- Pipe characters in markdown tables

Write the script to `/tmp/create-{repo-name}-issue.sh` and make it executable.

#### Hand Off to User

Tell the user to run:

```
/tmp/create-{repo-name}-issue.sh
```

Report the resulting issue URL after they execute it.

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
- **Always use `--body-file`** — never inline issue bodies in shell commands. Write to a temp file first
