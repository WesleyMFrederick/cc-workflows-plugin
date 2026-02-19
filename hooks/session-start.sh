#!/usr/bin/env bash
# SessionStart hook for local project - DRY session-scoped design

set -euo pipefail

# Determine script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Auto-install gh CLI in remote environments
GH_SETUP="${SCRIPT_DIR}/gh/setup.sh"
[[ -x "$GH_SETUP" ]] && "$GH_SETUP" >/dev/null 2>&1 || true

# Read using-superpowers content
using_superpowers_content=$(cat "${PROJECT_ROOT}/.claude/skills/using-superpowers/SKILL.md" 2>&1 || echo "Error reading using-superpowers skill")

# Read current-status.json if it exists and build status display
STATUS_FILE="${PROJECT_ROOT}/current-status.json"
current_status_block=""
status_display=""

if [[ -f "$STATUS_FILE" ]]; then
  status_content=$(cat "$STATUS_FILE")

  # Count active sessions
  session_count=$(echo "$status_content" | jq -r '.active_sessions | length // 0')
  max_sessions=$(echo "$status_content" | jq -r '.max_sessions // 5')

  if [[ "$session_count" -gt 0 ]]; then
    # Build active sessions display
    sessions_list=""
    idx=1

    # Iterate through active sessions
    for session_id in $(echo "$status_content" | jq -r '.active_sessions | keys[]'); do
      session=$(echo "$status_content" | jq -r ".active_sessions[\"$session_id\"]")
      focus=$(echo "$session" | jq -r '.focus // "No focus set"')
      status=$(echo "$session" | jq -r '.status // "unknown"')
      task_header=$(echo "$session" | jq -r '.current_task_header // empty')
      plan_path=$(echo "$session" | jq -r '.plan_path // empty')

      # Build task info string
      task_info=""
      if [[ -n "$task_header" && "$task_header" != "null" ]]; then
        task_info=" (${task_header})"
      fi

      # Build plan indicator
      plan_indicator=""
      if [[ -n "$plan_path" && "$plan_path" != "null" ]]; then
        plan_indicator=" [has plan]"
      fi

      short_id="${session_id:0:8}"
      sessions_list="${sessions_list}
${idx}. ${short_id} - \"${focus}\"${task_info} - ${status}${plan_indicator}"
      idx=$((idx + 1))
    done

    status_display="
📍 **Active Sessions (${session_count}/${max_sessions}):**${sessions_list}
"
  else
    status_display="
📍 **No active sessions** - Starting fresh
"
  fi

  current_status_block="
<current-status>
${status_content}
</current-status>

<current-status-instructions>
Session-scoped status tracking. When resuming:
1. Find your session in active_sessions by session_id
2. Check plan_path - use citation-manager to extract current task context
3. Update your session's last_active_at on each interaction
4. Derive resume context from plan file (DRY - don't store stale instructions)
</current-status-instructions>
${status_display}"
fi

# Build the additional context message
additional_context="<CRITICAL-INSTRUCTION>At the end of each response to the user, append the following content to the chat window exactly as shown, without any changes or omissions: _We are Oscar Mike_</CRITICAL-INSTRUCTION>
${current_status_block}

<EXTREMELY_IMPORTANT>
At the end of each response,

You have superpowers.

**The content below is from .claude/skills/using-superpowers/SKILL.md - your introduction to using skills:**

${using_superpowers_content}
</EXTREMELY_IMPORTANT>"

# Output context injection as JSON using jq for proper escaping
jq -n \
  --arg hookEvent "SessionStart" \
  --arg context "$additional_context" \
  '{
    hookSpecificOutput: {
      hookEventName: $hookEvent,
      additionalContext: $context
    }
  }'

exit 0
