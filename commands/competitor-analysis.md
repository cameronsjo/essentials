---
description: Analyze a new competitor from GitHub URL with full deep dive and landscape update
disable-model-invocation: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** have a GitHub URL in the arguments to proceed.

## Competitor Analysis Workflow

The text after `/competitor-analysis` should be a GitHub repository URL. Parse it and execute the following workflow:

### Step 1: Parse & Validate Input

1. Extract the GitHub URL from `$ARGUMENTS`
2. Validate it's a valid GitHub URL (e.g., `https://github.com/owner/repo`)
3. Extract `owner` and `repo` from the URL
4. If no valid URL found: ERROR "Please provide a GitHub repository URL"

### Step 2: Gather Intelligence

Use the market-researcher agent or direct tools to collect information in parallel:

**From GitHub (use `gh` CLI):**
```bash
# Basic repo info
gh repo view owner/repo --json name,description,stargazerCount,forkCount,updatedAt,licenseInfo,primaryLanguage,languages,repositoryTopics,homepageUrl

# Recent activity
gh repo view owner/repo --json pushedAt,createdAt,defaultBranchRef

# Contributors count
gh api repos/owner/repo/contributors --paginate -q 'length'
```

**From Repository Content (use WebFetch on raw.githubusercontent.com):**
- `README.md` - Overview and features
- `package.json` / `Cargo.toml` / `pyproject.toml` - Dependencies and tech stack
- Look for: `docs/`, `ARCHITECTURE.md`, `CONTRIBUTING.md`

**From Web (if has homepage):**
- Fetch homepage for marketing claims
- Check for documentation site

### Step 3: Analyze & Categorize

Based on gathered info, determine:

1. **What it is:** One-sentence description
2. **Type Classification:**
   - `orchestrator` - Multi-agent coordination
   - `toolkit` - Prompt/agent templates
   - `monitor` - Session/usage tracking
   - `integration` - External service connection
   - `config` - Configuration management
   - `utility` - Developer tools
   - `alternative` - Direct replacement/competitor

3. **Threat Level:**
   - Red **HIGH** - Direct competitor with significant traction (>5k stars, similar features)
   - Yellow **MEDIUM** - Partial overlap or emerging threat (1k-5k stars)
   - Green **LOW** - Complementary tool or niche solution (<1k stars)

4. **Key Features:** Extract 5-10 main capabilities

5. **Technical Architecture:**
   - Language/framework
   - Architecture pattern (client-server, CLI, desktop, etc.)
   - Key dependencies

6. **Our Relevance:**
   - Features to potentially adopt
   - Weaknesses we can exploit
   - Gaps in their offering

### Step 4: Create Analysis Document

Create `docs/research/{repo-name}-analysis.md` using this template:

```markdown
# {Repo Name} Competitor Analysis

**Date:** {TODAY} · **Repository:** {GitHub URL} · **License:** {License}
**Stars:** {Stars} · **Forks:** {Forks} · **Contributors:** {Count}
**Tech Stack:** {Primary language and key dependencies} · **Status:** {Active/Inactive}

---

## Executive Summary

{2-3 sentence overview of what this tool does and why it matters}

**Threat Level:** {HIGH/MEDIUM/LOW} - {One sentence justification}

**Type:** {orchestrator/toolkit/monitor/integration/config/utility/alternative}

---

## What It Does

{Detailed description of functionality - 3-5 paragraphs}

---

## Technical Architecture

{Architecture diagram if complex, otherwise describe the structure}

### Tech Stack

| Component | Technology |
|-----------|------------|
| Language | {Primary language} |
| Framework | {Key frameworks} |
| Dependencies | {Notable deps} |

### Key Files/Structure

| Path | Purpose |
|------|---------|
| {path} | {purpose} |

---

## Key Features

| Feature | Description |
|---------|-------------|
| {Feature 1} | {Description} |
| {Feature 2} | {Description} |
...

---

## Installation & Usage

\```bash
{Installation commands}
\```

{Brief usage example}

---

## Strengths

1. {Strength 1}
2. {Strength 2}
...

---

## Weaknesses

1. {Weakness 1}
2. {Weakness 2}
...

---

## Gap Analysis: Our Opportunities

| Capability | {Repo} | Our Opportunity |
|------------|--------|-----------------|
| {Feature} | {Yes/No/Partial} | {Opportunity} |
...

---

## Features Worth Stealing

| Feature | Effort | Impact | Priority |
|---------|--------|--------|----------|
| {Feature} | {Low/Medium/High} | {Description} | {High/Medium/Low} |
...

---

## Strategic Assessment

### Threat Level: {HIGH/MEDIUM/LOW}

{2-3 paragraphs on competitive positioning}

### Our Differentiation

{How we differ and should position against this competitor}

### Recommended Actions

1. **Immediate:** {Action}
2. **Short-term:** {Action}
3. **Medium-term:** {Action}

---

## References

- [GitHub Repository]({URL})
- {Other relevant links}

---

**Last Updated:** {TODAY}
```

### Step 5: Update Competitive Landscape

Read `docs/research/competitive-landscape.md` and update it:

1. **Add to Threat Matrix** if HIGH or MEDIUM threat
2. **Add to Top Competitors section** if HIGH threat
3. **Update Feature Landscape** tables if it introduces new patterns
4. **Add to "Ideas Worth Stealing"** section with extracted features
5. **Update Documentation Index** at bottom

### Step 6: Report Completion

Output a summary:

```markdown
## Competitor Analysis Complete

### {Repo Name}

| Metric | Value |
|--------|-------|
| Type | {type} |
| Threat Level | {threat} |
| Stars | {stars} |
| Key Insight | {one sentence} |

### Documents Updated

- Created: `docs/research/{repo-name}-analysis.md`
- Updated: `docs/research/competitive-landscape.md`

### Features to Consider

1. {Top feature 1}
2. {Top feature 2}
3. {Top feature 3}

### Next Steps

- Review the full analysis at `docs/research/{repo-name}-analysis.md`
- Consider adding to roadmap: {key feature}
```

## Guidelines

### Research Depth

- **HIGH threat:** Deep dive - architecture, code review, community analysis
- **MEDIUM threat:** Standard analysis - features, tech stack, gaps
- **LOW threat:** Quick summary - description, threat assessment, skip detailed analysis

### When Information is Unavailable

- Don't fabricate data - mark as "Unknown" or "Not available"
- Focus on what can be determined from public sources
- Note gaps in your analysis

### Date Format

Use ISO format: YYYY-MM-DD

### File Naming

- Lowercase
- Hyphens instead of spaces
- Suffix with `-analysis.md`
- Example: `claude-squad-analysis.md`
