---
name: reminders
description: Create, query, complete, and delete macOS Reminders. Use when the user asks to set a reminder, check their tasks, mark something done, or automate recurring task creation.
---

# Reminders

Manage macOS Reminders programmatically via JXA (JavaScript for Automation). JXA is required over AppleScript because the `repeat` property is a reserved keyword in AppleScript.

## When to Use

- User says "remind me to...", "set a reminder", "add a task"
- User asks to check their reminders or overdue tasks
- User wants recurring reminders (biweekly, daily, etc.)
- User asks to mark something complete or delete a reminder

## Do Not Ask

- Which list to use — default to the user's default list unless they specify
- Whether to set a remind-me notification — always set `remindMeDate` equal to `dueDate` so they get an alert
- Confirmation before creating — just create it and report back

## Operations

### Create a Reminder

Use JXA via `osascript -l JavaScript`. All properties are optional except `name`.

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const list = app.defaultList();
const r = app.Reminder({
  name: "TITLE",
  body: "NOTES",
  dueDate: new Date("YYYY-MM-DDTHH:MM:SS"),
  remindMeDate: new Date("YYYY-MM-DDTHH:MM:SS"),
  priority: 0,
  flagged: false
});
list.reminders.push(r);
"Done"
'
```

#### With Recurrence

Add the `repeat` property at creation time. It cannot be modified after creation.

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const list = app.defaultList();
const r = app.Reminder({
  name: "Weekly standup prep",
  dueDate: new Date("2026-03-02T09:00:00"),
  remindMeDate: new Date("2026-03-02T09:00:00"),
  repeat: "every week"
});
list.reminders.push(r);
"Done"
'
```

**Valid repeat values:**

| Value | Pattern |
|-------|---------|
| `"every day"` | Daily |
| `"every weekday"` | Mon–Fri |
| `"every week"` | Weekly |
| `"every other week"` | Biweekly |
| `"every other day"` | Every 2 days |
| `"every month"` | Monthly |
| `"every year"` | Yearly |

#### To a Specific List

```javascript
const list = app.lists.whose({name: "Work"})[0];
```

### Properties Reference

| Property | Type | Create | Read | Notes |
|----------|------|--------|------|-------|
| `name` | String | Yes | Yes | Title (required) |
| `body` | String | Yes | Yes | Description/notes |
| `dueDate` | Date | Yes | Yes | Due date with time |
| `alldayDueDate` | Date | Yes | Yes | All-day due date (no time) |
| `remindMeDate` | Date | Yes | Yes | When to fire notification |
| `priority` | Integer | Yes | Yes | 0=none, 1=low, 2=medium, 3=high |
| `flagged` | Boolean | Yes | Yes | Orange flag |
| `completed` | Boolean | Yes | Yes | Completion status |
| `repeat` | String | Yes | No | Write-once at creation (JXA only) |
| `id` | String | — | Yes | Read-only URI |
| `creationDate` | Date | — | Yes | Read-only |
| `completionDate` | Date | — | Yes | Read-only |

### Query Reminders

**List incomplete reminders (default list):**

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const reminders = app.defaultList().reminders.whose({completed: false})();
reminders.map(r => {
  const due = r.dueDate() ? r.dueDate().toLocaleDateString() : "no date";
  const pri = ["", "!", "!!", "!!!"][r.priority()] || "";
  return `${pri} ${r.name()} [${due}]`;
}).join("\n");
'
```

**List overdue reminders:**

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const now = new Date();
const reminders = app.defaultList().reminders.whose({completed: false})();
const overdue = reminders.filter(r => {
  const due = r.dueDate();
  return due && due < now;
});
overdue.map(r => `${r.name()} — due ${r.dueDate().toLocaleDateString()}`).join("\n") || "No overdue reminders";
'
```

**Search by name:**

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const reminders = app.defaultList().reminders.whose({name: {_contains: "SEARCH_TERM"}})();
reminders.map(r => `${r.completed() ? "✓" : "○"} ${r.name()}`).join("\n");
'
```

**List all lists:**

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
app.lists().map(l => l.name()).join("\n");
'
```

### Complete a Reminder

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const matches = app.defaultList().reminders.whose({name: {_contains: "SEARCH_TERM"}})();
if (matches.length === 0) { "No match found"; }
else { matches[0].completed = true; `Completed: ${matches[0].name()}`; }
'
```

### Delete a Reminder

```bash
osascript -e '
tell application "Reminders"
  delete (every reminder of default list whose name contains "SEARCH_TERM")
end tell
'
```

### Update a Reminder

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const matches = app.defaultList().reminders.whose({name: {_contains: "SEARCH_TERM"}})();
if (matches.length === 0) { "No match found"; }
else {
  const r = matches[0];
  r.body = "Updated notes";
  r.dueDate = new Date("2026-04-01T10:00:00");
  r.priority = 2;
  `Updated: ${r.name()}`;
}
'
```

## Interpretation Guide

When the user says something vague, interpret:

| User says | Interpret as |
|-----------|-------------|
| "remind me Friday" | Next Friday at 9:00 AM |
| "remind me in 2 hours" | Current time + 2 hours |
| "remind me tomorrow morning" | Tomorrow at 9:00 AM |
| "remind me end of day" | Today at 5:00 PM |
| "remind me every two weeks" | `repeat: "every other week"` |
| "high priority" | `priority: 3` |
| "flag it" | `flagged: true` |

## Limitations

- `repeat` is **write-once** — set at creation, cannot be read back or modified programmatically
- To change recurrence, delete and recreate the reminder
- Location-based reminders are not supported via JXA
- Subtasks/sub-reminders are not accessible via the scripting API
- Tags (new in macOS Ventura+) are not exposed to the scripting bridge
