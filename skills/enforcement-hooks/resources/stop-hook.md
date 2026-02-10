# Stop Hook Documentation

## Overview

The Stop hook provides an intelligent quality gate when exiting Claude Code sessions. It analyzes the session to determine if work is genuinely complete before allowing you to exit.

## How It Works

**Trigger:** Runs when you attempt to exit a session (`/exit` or similar)

**Logic:**

1. Checks `stop_hook_active` flag to prevent infinite loops
2. Analyzes session transcript to understand what work was done
3. Determines if work is complete based on:
   - Original user goal accomplished
   - All code changes implemented
   - Tests passing (if applicable)
   - No orphaned TODOs/FIXMEs
   - Documentation updated
4. Either allows exit or blocks with explanation of what's missing

## Session Types

**Automatically allows exit:**

- Exploratory sessions (reading code, asking questions)
- Configuration-only sessions (editing settings, .zshrc, etc.)
- Sessions where all work is complete

**May block exit:**

- Active development with incomplete features
- Failing tests
- Orphaned TODOs without issue references
- Missing documentation for new features

## Preventing Infinite Loops

The hook includes a critical safety mechanism:

**First exit attempt:** Hook evaluates session normally

- If complete → allows exit
- If incomplete → blocks with explanation

**Second exit attempt:** Hook sees `stop_hook_active=true` and always allows exit

- This ensures you can always force-exit if needed
- Just try exiting twice

## Configuration

Located in `~/.claude/settings.json`:

```json
"Stop": [
  {
    "hooks": [
      {
        "type": "prompt",
        "prompt": "...",
        "timeout": 30
      }
    ]
  }
]
```

**Type:** Prompt (LLM-based evaluation)
**Timeout:** 30 seconds
**Response format:** `{"decision": "block" | null, "reason": "..."}`

## Example Scenarios

### Scenario 1: Configuration Session

```bash
$ /exit
✓ Session complete (configuration changes only)
Catch you later!
```

### Scenario 2: Incomplete Work

```bash
$ /exit
⏺ Ran 1 stop hook
  ⎿ Tests are failing in user-service.test.ts
  ⎿ Stop blocked: Fix 3 failing tests, then continue

Claude continues working...
```

### Scenario 3: Force Exit

```bash
$ /exit
⏺ Ran 1 stop hook
  ⎿ Work incomplete but allowing exit (stop_hook_active=true)
Catch you later!
```

## Customization

To adjust hook behavior, edit the prompt in `settings.json`:

- **Make stricter:** Add more checks (linting, build status, etc.)
- **Make lenient:** Adjust criteria for "complete"
- **Change timeout:** Increase if sessions are very long

## Disabling

To temporarily disable, set `"Stop": []` in settings.json.

## Troubleshooting

**Hook blocks every exit:**

- Check if `stop_hook_active` check is working
- Verify JSON response format is correct
- Try exiting twice (second attempt should always work)

**Hook never blocks:**

- Verify hook is in settings.json
- Check Claude Code loaded the updated config (restart if needed)
- Review prompt logic for edge cases

## Performance

**Typical latency:** 2-5 seconds per exit attempt

**Token usage:** Minimal (only when exiting sessions)

## Related Hooks

- **PreToolUse hooks:** Catch issues before they happen (orphaned TODOs, bad terminology)
- **PostToolUse hooks:** Validate after operations (untracked files warning)
- **SessionStart hooks:** Initialize session state

## Version

Stop hook implemented: November 2025
Based on: Claude Code official documentation
Format: `{"decision": "block" | null, "reason": "..."}`
