#!/bin/bash
# PostToolUse(TaskCreate|TaskUpdate) hook: Sync task state to current-status.json
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
STATUS_FILE="${PROJECT_ROOT}/current-status.json"

# Source shared helpers
source "${SCRIPT_DIR}/../lib/status-helpers.sh"

INPUT=$(cat)

session_id=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
[[ -z "$session_id" ]] && exit 0
[[ ! -f "$STATUS_FILE" ]] && exit 0

# Use shared helper
scan_tasks "$session_id"

# Get plan_path from status
plan_path=$(jq -r --arg sid "$session_id" '.active_sessions[$sid].plan_path // empty' "$STATUS_FILE" 2>/dev/null)

# Resolve header if we have both plan and task
current_task_header=""
if [[ -n "$plan_path" && -n "$TASK_NUMBER" ]]; then
  current_task_header=$(resolve_task_header "$plan_path" "$TASK_NUMBER")
fi

# Derive focus: from plan, or from task summary, or keep existing
focus_update=""
if [[ -n "$plan_path" && -f "$plan_path" ]]; then
  focus_update=$(derive_focus_from_plan "$plan_path")
elif [[ -n "$TASK_SUMMARY" ]]; then
  # No plan but has task - use task summary as focus
  focus_update="$TASK_SUMMARY"
fi

# Update current-status.json
jq --arg sid "$session_id" \
   --arg task_num "${TASK_NUMBER:-}" \
   --arg tasks_path "${TASKS_DIR:-}" \
   --arg task_sum "${TASK_SUMMARY:-}" \
   --arg task_hdr "${current_task_header:-}" \
   --arg focus "${focus_update:-}" \
   '.active_sessions[$sid].current_task_number = (if $task_num == "" then null else $task_num end) |
    .active_sessions[$sid].tasks_path = (if $tasks_path == "" then null else $tasks_path end) |
    .active_sessions[$sid].task_summary = (if $task_sum == "" then null else $task_sum end) |
    .active_sessions[$sid].current_task_header = (if $task_hdr == "" then null else $task_hdr end) |
    (if $focus != "" then .active_sessions[$sid].focus = $focus else . end)' \
   "$STATUS_FILE" > "${STATUS_FILE}.tmp.$$" && mv "${STATUS_FILE}.tmp.$$" "$STATUS_FILE"

exit 0
