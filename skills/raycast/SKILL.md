---
name: raycast
description: Configure Raycast productivity features for developers. Use when setting up snippets, script commands, hotkeys, quicklinks, or window management. Covers creating text expansions, shell script integrations, and workflow automation for macOS.
---

# Raycast Configuration

Raycast is a keyboard-driven productivity launcher for macOS. This skill helps configure its most valuable features for developers.

## Feature Priority (Developer Workflow)

| Priority | Feature | Setup Time | Daily Value |
|----------|---------|------------|-------------|
| 1 | Clipboard History | None | High |
| 2 | Snippets | 5 min | High |
| 3 | Window Management | 2 min | Medium |
| 4 | Script Commands | 10 min | High |
| 5 | Quicklinks | 5 min | Medium |
| 6 | App Hotkeys | 2 min | Medium |

## Snippets

Text expansions that trigger when you type a keyword.

### Format

- **Keyword**: Short trigger (e.g., `;;gh`, `!!email`)
- **Expansion**: Text to insert (supports `{cursor}` placeholder)
- **Use double symbols** to avoid accidental triggers: `;;`, `!!`, `//`

### Creating Snippets

1. Open Raycast → Search "Create Snippet"
2. Or: Raycast Settings → Extensions → Snippets → Add

### Snippet Design Principles

- **Prefix by category**: `;;git-*`, `;;docker-*`, `;;k8s-*`
- **Keep keywords memorable**: Related to the output
- **Use cursor placement**: `{cursor}` positions cursor after expansion
- **Include placeholders**: `{name}` for fill-in values


## Script Commands

Shell scripts that run from Raycast with a keyboard shortcut.

### Script Header Format

```bash
#!/bin/bash

# Required Metadata
# @raycast.title Human Readable Title
# @raycast.mode compact|silent|fullOutput|inline

# Optional Metadata
# @raycast.packageName Group Name
# @raycast.icon 🚀
# @raycast.argument1 { "type": "text", "placeholder": "Search term" }
# @raycast.description What this script does
```

### Output Modes

| Mode | Behavior |
|------|----------|
| `compact` | Shows output briefly, then closes |
| `silent` | No output shown |
| `fullOutput` | Opens panel with full output |
| `inline` | Shows output in Raycast bar |

### Script Location

Store scripts in a dedicated directory and add it to Raycast:
1. Raycast Settings → Extensions → Script Commands
2. Add your scripts directory

**Recommended location:** `~/bin/raycast/` or your dotfiles directory.

Add to Raycast: Settings → Extensions → Script Commands → Add your scripts directory.

### Script Examples

See [scripts/](./scripts/) for example script commands. Copy to your scripts directory:

```bash
for f in ~/.claude/skills/raycast/scripts/*.sh; do
  cp "$f" ~/bin/raycast/
  chmod +x ~/bin/raycast/$(basename "$f")
done
```

## Window Management

Built-in window snapping with keyboard shortcuts.

### Essential Shortcuts

| Action | Default | Suggested |
|--------|---------|-----------|
| Left Half | `⌃⌥ ←` | Keep |
| Right Half | `⌃⌥ →` | Keep |
| Maximize | `⌃⌥ ↩` | Keep |
| Center | `⌃⌥ C` | Keep |
| Restore | `⌃⌥ ⌫` | Keep |

### Setup

Raycast Settings → Extensions → Window Management → Configure hotkeys

## Quicklinks

Open URLs or files with a keyword.

### Format

```
Name: Grafana Local
Link: http://localhost:3000
Keyword: grafana
```

### Dynamic Parameters

Use `{query}` for search URLs:
```
Name: GitHub Search
Link: https://github.com/search?q={query}
Keyword: ghs
```

### Setup

Raycast Settings → Extensions → Quicklinks → Add

## App Hotkeys

Assign global hotkeys to launch or focus apps.

### Setup

1. Open Raycast
2. Search for app name
3. Press `⌘ K` → "Configure Hotkey"
4. Set your shortcut

### Suggested Hotkeys

| App | Hotkey |
|-----|--------|
| Terminal/Ghostty | `⌃⌥ T` |
| Browser | `⌃⌥ B` |
| VS Code/IDE | `⌃⌥ E` |
| Slack | `⌃⌥ S` |

## Extensions

Install from Raycast Store (search "Store" in Raycast).

### Recommended for Developers

| Extension | Purpose |
|-----------|---------|
| GitHub | Search repos, PRs, issues |
| Brew | Search and install packages |
| Docker | Manage containers |
| Port Manager | See what's using ports |
| Kill Process | Force quit by name |
| Tailwind CSS | Search docs and classes |
| VS Code | Open projects, run commands |

### Enterprise GitHub Note

The GitHub extension may not support enterprise GitHub instances. Use script commands with `gh` CLI and `GH_HOST` instead.

## Configuration Backup

Raycast settings sync via iCloud or can be exported:
- Raycast Settings → Advanced → Export

For dotfiles management, consider creating snippets/scripts in your dotfiles repo and importing them.

## Troubleshooting

### Snippets Not Expanding
- Check keyword doesn't conflict with other text expanders
- Ensure Raycast has Accessibility permissions
- Try different prefix (`;; ` vs `!!`)

### Scripts Not Appearing
- Verify script is executable: `chmod +x script.sh`
- Check script has valid Raycast metadata header
- Restart Raycast after adding new scripts

### Hotkeys Not Working
- Check for conflicts in System Settings → Keyboard → Shortcuts
- Some apps capture shortcuts before Raycast

## Resources

- [Raycast Manual](https://manual.raycast.com/)
- [Script Commands Repository](https://github.com/raycast/script-commands)
- [Extension Store](https://www.raycast.com/store)
- [API Documentation](https://developers.raycast.com/)
