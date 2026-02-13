#!/bin/bash
# Memory line-count enforcement for auto memory files.
# Fires on Write/Edit — blocks MEMORY.md over 200 lines, warns over 180.
# Topic files get a softer 300-line warning.

input=$(cat)

file_path=$(echo "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
[[ -z "$file_path" ]] && exit 0

# Only care about memory files
[[ "$file_path" == */memory/* ]] || exit 0

# For Write tool: count lines in the content being written
# For Edit tool: count lines of the target file after edit would apply
# Since we can't predict post-edit state, check current file + warn if close
basename=$(basename "$file_path")

if [[ "$basename" == "MEMORY.md" ]]; then
  # Try to get line count from proposed content (Write tool)
  content=$(echo "$input" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('content', ''))
except:
    pass
" 2>/dev/null)

  if [[ -n "$content" ]]; then
    line_count=$(echo "$content" | wc -l | tr -d ' ')
  elif [[ -f "$file_path" ]]; then
    line_count=$(wc -l < "$file_path" | tr -d ' ')
  else
    exit 0
  fi

  if [[ "$line_count" -gt 200 ]]; then
    echo "MEMORY.md is ${line_count} lines (limit: 200). Fan out to topic files or prune stale entries. Run \`/field-notes review\` to clean up."
    exit 2
  elif [[ "$line_count" -gt 180 ]]; then
    echo "MEMORY.md is ${line_count}/200 lines. Consider running \`/field-notes review\`."
    exit 0
  fi
else
  # Topic file — softer limit
  if [[ -f "$file_path" ]]; then
    line_count=$(wc -l < "$file_path" | tr -d ' ')
    if [[ "$line_count" -gt 300 ]]; then
      echo "Topic file $(basename "$file_path") is ${line_count} lines (soft limit: 300). Consider splitting or pruning."
      exit 0
    fi
  fi
fi

exit 0
