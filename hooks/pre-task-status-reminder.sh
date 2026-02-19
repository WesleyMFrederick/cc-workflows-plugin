#!/bin/bash

# Pre-Task Status Reminder Hook
# Fires before spawning a Task tool (subagent)
# Reminds to update current-status.json before delegating work

set -euo pipefail

# Determine project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

STATUS_FILE="${PROJECT_ROOT}/current-status.json"
REMINDER=""

if [[ -f "$STATUS_FILE" ]]; then
  current_status=$(jq -r '.status // "pending"' "$STATUS_FILE" 2>/dev/null)
  queue_count=$(jq -r '.plan_queue | length // 0' "$STATUS_FILE" 2>/dev/null)

  if [[ "$current_status" == "in_progress" ]]; then
    queue_info=""
    if [[ "$queue_count" -gt 0 ]]; then
      queue_info=" (${queue_count} plans queued)"
    fi

    REMINDER="<pre-task-status-reminder>
**Before spawning subagent:** Update current-status.json:
- notes: What you're delegating and why${queue_info}
- timestamp: Current ISO-8601 time
This preserves context if session is interrupted.
</pre-task-status-reminder>"
  fi
fi

# Output JSON with reminder if applicable
if [[ -n "$REMINDER" ]]; then
  jq -n \
    --arg context "$REMINDER" \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "additionalContext": $context
      }
    }'
else
  echo '{}'
fi

exit 0
