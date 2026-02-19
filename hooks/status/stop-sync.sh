#!/bin/bash
# Stop hook: Sync session status with haiku-derived focus
# Reads transcript, calls haiku for focus summary (if no plan), updates status

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
STATUS_FILE="${PROJECT_ROOT}/current-status.json"

# Source shared helpers
source "${SCRIPT_DIR}/../lib/status-helpers.sh"

INPUT=$(cat)

# Extract from stdin
session_id=$(echo "$INPUT" | jq -r '.session_id')
transcript_path=$(echo "$INPUT" | jq -r '.transcript_path')
stop_hook_active=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Skip if already in stop hook (prevent loops)
[[ "$stop_hook_active" == "true" ]] && exit 0

# Skip if no status file
[[ ! -f "$STATUS_FILE" ]] && exit 0

# Timing helper (macOS compatible)
get_ms() {
  python3 -c 'import time; print(int(time.time() * 1000))'
}

# Timing: Start
start_ms=$(get_ms)

# Check if session has a plan_path
plan_path=$(jq -r --arg sid "$session_id" '.active_sessions[$sid].plan_path // empty' "$STATUS_FILE" 2>/dev/null)

if [[ -n "$plan_path" && -f "$plan_path" ]]; then
  # Use shared helper for focus derivation
  focus=$(derive_focus_from_plan "$plan_path")
  skipped_haiku=true
  haiku_duration_ms=0
else
  # Extract user text messages only (filter tool_results, keep only plain text)
  user_messages=$(jq -s '
    [.[] | select(.type == "user") | .message.content |
      if type == "string" then .
      elif type == "array" then [.[] | select(type == "string")] | join(" ")
      else empty end
    ] | map(select(length > 0)) | join("\n---\n")
  ' "$transcript_path" 2>/dev/null || echo "")

  # Timing: After transcript read
  read_ms=$(get_ms)
  deterministic_ms=$((read_ms - start_ms))

  # Call haiku for focus summary (run from /tmp to avoid project context)
  focus=$(cd /tmp && echo "$user_messages" | claude -p \
    --model haiku \
    --output-format json \
    "Summarize the main topic of this conversation in 3-5 words. Output ONLY the summary, nothing else." \
    2>/dev/null | jq -r '.result // "Unknown focus"')

  # Timing: After haiku
  haiku_ms=$(get_ms)
  haiku_duration_ms=$((haiku_ms - read_ms))
  skipped_haiku=false
fi

# Use shared helper for task scanning
scan_tasks "$session_id"

# Use shared helper for header resolution
current_task_header=""
if [[ -n "$plan_path" && -n "$TASK_NUMBER" ]]; then
  current_task_header=$(resolve_task_header "$plan_path" "$TASK_NUMBER")
fi

# Timing: End
end_ms=$(get_ms)
total_ms=$((end_ms - start_ms))

# Update current-status.json
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq --arg sid "$session_id" \
   --arg focus "$focus" \
   --arg ts "$timestamp" \
   --arg task_num "${TASK_NUMBER:-}" \
   --arg tasks_path "${TASKS_DIR:-}" \
   --arg task_sum "${TASK_SUMMARY:-}" \
   --arg task_hdr "${current_task_header:-}" \
   '.active_sessions[$sid].focus = $focus |
    .active_sessions[$sid].status = "idle" |
    .active_sessions[$sid].last_active_at = $ts |
    .active_sessions[$sid].current_task_number = (if $task_num == "" then null else $task_num end) |
    .active_sessions[$sid].tasks_path = (if $tasks_path == "" then null else $tasks_path end) |
    .active_sessions[$sid].task_summary = (if $task_sum == "" then null else $task_sum end) |
    .active_sessions[$sid].current_task_header = (if $task_hdr == "" then null else $task_hdr end)' \
   "$STATUS_FILE" > "${STATUS_FILE}.tmp.$$" && mv "${STATUS_FILE}.tmp.$$" "$STATUS_FILE"

# Log metrics to stderr (visible in claude --debug)
echo "[stop-sync] session=$session_id focus=\"$focus\" task=\"${TASK_SUMMARY:-none}\" skipped_haiku=$skipped_haiku haiku_ms=$haiku_duration_ms total_ms=$total_ms" >&2

exit 0
