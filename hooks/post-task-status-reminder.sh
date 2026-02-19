#!/bin/bash

# Post-Task Status Reminder Hook
# Fires after a Task tool (subagent) completes
# Reminds to update current-status.json with results

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
      queue_info="
- plan_queue: Remove completed plan if applicable (${queue_count} in queue)"
    fi

    REMINDER="<post-task-status-reminder>
**Subagent completed.** Update current-status.json:
- current_phase: What you're working on now
- last_completed_phase: What was just finished
- phases_completed: Add completed phase
- phases_remaining: Remove completed phase
- notes: Key outcomes
- timestamp: Current ISO-8601 time${queue_info}

Note: Session tracking (session_history) is updated automatically.
</post-task-status-reminder>"
  fi
fi

# Output JSON with reminder if applicable
if [[ -n "$REMINDER" ]]; then
  jq -n \
    --arg context "$REMINDER" \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": $context
      }
    }'
else
  echo '{}'
fi

exit 0
