# Essentials

Core developer workflow toolkit — session rhythm, productivity commands, git maintenance, skill building, and documentation. The desk where you start and end your day.

Designed alongside [dev-toolkit](https://github.com/cameronsjo/dev-toolkit) (building/shipping tools) and [vibes](https://github.com/cameronsjo/vibes) (personality modes).

## Commands

### Session Rhythm

| Command | Description |
|---------|-------------|
| `/good-morning` | Start-of-day orientation — git status, memory context, recent activity |
| `/good-afternoon` | Re-orient after `/clear` or compaction — reload uncommitted changes |
| `/good-evening` | End-of-session cleanup — multi-Claude git checks, commits, pushes, memory save |
| `/coffee-break` | Quick checkpoint — commit and push uncommitted work across all repos |
| `/lunch-break` | Mid-session memory save — capture learnings before compaction |

### Work

| Command | Description |
|---------|-------------|
| `/a-star-is-born` | Scaffold a new project or retrofit — Beads, OpenSpec, AGENTS.md, Makefile, CI |
| `/field-notes` | Capture or review session insights and gotchas |
| `/field-report` | Write a detailed session narrative to `docs/field-reports/` |
| `/shuffle-papers` | Sort, standardize, and triage documentation |
| `/tidy-your-workspace` | Clean up git branches, worktrees, stale refs, stashes |

### Utilities

| Command | Description |
|---------|-------------|
| `/root-cause` | Five Whys root cause analysis |
| `/competitor-analysis` | Analyze a competitor from GitHub URL |
| `/create-onboarding-guide` | Create developer onboarding guide |
| `/doc-to-reference` | Convert PDFs, URLs, or docs into structured markdown |

## Skills

Skills are invoked automatically when context matches, or explicitly by name.

| Skill | Description |
|-------|-------------|
| `good-morning` | Start-of-day scan |
| `good-afternoon` | Post-clear re-orient |
| `good-evening` | End-of-session cleanup |
| `coffee-break` | Quick git checkpoint |
| `lunch-break` | Memory save |
| `a-star-is-born` | Project scaffolding |
| `field-notes` | Insight capture |
| `field-report` | Session narrative |
| `shuffle-papers` | Doc triage |
| `tidy-your-workspace` | Git maintenance |
| `git-worktrees` | Worktree management and branch workflows |
| `skill-builder` | Build proper Claude skills with correct structure |
| `github-issue` | Write structured GitHub issues |
| `enforcement-hooks` | Claude Code hooks for engineering standards |
| `data-storytelling` | Transform data into narratives (What/Why/Next) |
| `personal-brand` | Build developer presence |
| `conflict-resolution` | Neutralize workplace conflicts (MOAR framework) |
| `raycast` | Configure Raycast productivity features |
| `reminders` | Manage macOS Reminders |

## Install

```bash
claude plugin install essentials@workbench
claude plugin enable essentials@workbench
```

## License

MIT
