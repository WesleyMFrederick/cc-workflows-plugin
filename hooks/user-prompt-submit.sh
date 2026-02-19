#!/bin/bash

# CEO Output Modulation Hook + Session Sync
# DRY session-scoped design - derives context from plan, not stale fields

set -euo pipefail

# Read stdin (hook context)
INPUT=$(cat)

# Determine project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

STATUS_FILE="${PROJECT_ROOT}/current-status.json"

# Session sync function - manages session-scoped active_sessions
sync_session() {
  local session_id timestamp max_sessions session_count

  session_id=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

  # Skip if no session_id
  [[ -z "$session_id" ]] && return 0

  # Create status file if missing
  if [[ ! -f "$STATUS_FILE" ]]; then
    echo '{"active_sessions": {}, "max_sessions": 15}' > "$STATUS_FILE"
  fi

  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  max_sessions=$(jq -r '.max_sessions // 15' "$STATUS_FILE" 2>/dev/null)
  session_count=$(jq -r '.active_sessions | length' "$STATUS_FILE" 2>/dev/null)

  # Check if session exists
  local session_exists
  session_exists=$(jq -r --arg sid "$session_id" '.active_sessions[$sid] // empty' "$STATUS_FILE" 2>/dev/null)

  if [[ -z "$session_exists" ]]; then
    # New session - enforce FIFO limit (prioritize removing planless sessions)
    if [[ "$session_count" -ge "$max_sessions" ]]; then
      # First try: remove oldest "New session" (no plan, default focus)
      local planless_id
      planless_id=$(jq -r '[.active_sessions | to_entries[] | select(.value.plan_path == null) | {key, time: .value.last_active_at}] | sort_by(.time) | .[0].key // empty' "$STATUS_FILE" 2>/dev/null)

      if [[ -n "$planless_id" && "$planless_id" != "null" ]]; then
        # Safe to remove - no plan attached
        jq --arg old "$planless_id" 'del(.active_sessions[$old])' "$STATUS_FILE" > "${STATUS_FILE}.tmp.$$" && mv "${STATUS_FILE}.tmp.$$" "$STATUS_FILE"
      else
        # All sessions have plans - don't auto-remove, set flag for permission request
        export SESSIONS_FULL_WITH_PLANS="true"
        return 0  # Don't add new session - need user permission first
      fi
    fi

    # Add new session entry
    jq --arg sid "$session_id" \
       --arg ts "$timestamp" \
       '.active_sessions[$sid] = {
         plan_path: null,
         current_task_header: null,
         focus: "New session",
         status: "active",
         last_active_at: $ts
       }' "$STATUS_FILE" > "${STATUS_FILE}.tmp.$$" && mv "${STATUS_FILE}.tmp.$$" "$STATUS_FILE"
  else
    # Existing session - update last_active_at
    jq --arg sid "$session_id" \
       --arg ts "$timestamp" \
       '.active_sessions[$sid].last_active_at = $ts |
    .active_sessions[$sid].status = "active"' \
       "$STATUS_FILE" > "${STATUS_FILE}.tmp.$$" && mv "${STATUS_FILE}.tmp.$$" "$STATUS_FILE"
  fi
}

# Run session sync (silent - errors don't block hook)
sync_session 2>/dev/null || true

# Check if sessions are full with plans (set by sync_session)
SESSION_LIMIT_WARNING=""
if [[ "${SESSIONS_FULL_WITH_PLANS:-}" == "true" ]]; then
  SESSION_LIMIT_WARNING="
<session-limit-warning>
**Session limit reached (all ${max_sessions:-5} sessions have plans).**
Ask user which session to remove before creating new one.
Show: session ID, focus, plan_path for each.
</session-limit-warning>"
fi

# CEO output preferences (always active)
CEO_DIRECTIVES="<system-notification>
<ceo-output-preferences>
**HOOK_TEST_MARKER_CEO_OUTPUT_HOOK_ACTIVE**

**Context:** User is CEO - time-sensitive, needs scannable output.

**Chat Output Rules:**
- Keep responses CONCISE and SCANNABLE
- Use bullets, short paragraphs, clear headers
- Front-load key information
- Omit verbose explanations unless explicitly requested

**Explaining Configuration:**
- Show BOTH the concept AND the concrete: file path, current content, exact edit
- Default to "here's what to paste" alongside "here's why"
- Never give abstract instructions without showing the actual file to edit

**File Output Rules:**
- Detailed documentation allowed in files
- Code comments, full examples acceptable

**Presenting Options:**
- ALWAYS use numbered lists OR AskUserQuestion tool
- Never present options in prose paragraphs
- When using AskUserQuestion: ALWAYS include your recommendation
  • State preference IN the question: \"I recommend [X] because [Y]\"
  • Explain trade-offs for all options in their descriptions
  • Guide the decision - don't just present choices
  • Example: \"Which approach? I recommend parallel execution because it validates assumptions faster with minimal additional code.\"

**Adding Detail:**
- Provide detail ONLY when CEO explicitly requests it
- Default to minimal necessary information
- Ask 'Need more detail?' rather than over-explaining

**Summary:** Be brief. Be clear. Be actionable.
</ceo-output-preferences>
</system-notification>"

# Output JSON with combined context
jq -n \
  --arg context "${CEO_DIRECTIVES}${SESSION_LIMIT_WARNING}" \
  '{
    "hookSpecificOutput": {
      "hookEventName": "UserPromptSubmit",
      "additionalContext": $context
    }
  }'

exit 0
