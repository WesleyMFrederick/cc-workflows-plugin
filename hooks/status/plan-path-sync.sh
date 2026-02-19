#!/bin/bash
# PostToolUse(Write|Edit) hook: Auto-populate plan_path for various plan types
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
STATUS_FILE="${PROJECT_ROOT}/current-status.json"

# Source shared helpers
source "${SCRIPT_DIR}/../lib/status-helpers.sh"

INPUT=$(cat)

# Extract file path and session
file_path=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
session_id=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

# Early exit checks
[[ -z "$file_path" || -z "$session_id" ]] && exit 0
[[ ! -f "$STATUS_FILE" ]] && exit 0

# Pattern matching for plan types (all development workflow phases)
is_plan_file=false

# Claude Code plans
if [[ "$file_path" =~ \.claude/plans/.*\.md$ ]]; then
  is_plan_file=true
fi

# Phase 1: Discovery whiteboards
if [[ "$file_path" =~ design-docs/.*whiteboard.*\.md$ ]]; then
  is_plan_file=true
fi

# Phase 1 output: PRD/Requirements
if [[ "$file_path" =~ design-docs/.*(prd|requirements).*\.md$ ]]; then
  is_plan_file=true
fi

# Phase 2: Design docs
if [[ "$file_path" =~ design-docs/.*design.*\.md$ ]]; then
  is_plan_file=true
fi

# Phase 3: Sequencing docs
if [[ "$file_path" =~ design-docs/.*sequencing.*\.md$ ]]; then
  is_plan_file=true
fi

# Phase 4: Implementation plans
if [[ "$file_path" =~ design-docs/.*implement.*\.md$ ]]; then
  is_plan_file=true
fi

[[ "$is_plan_file" == "false" ]] && exit 0

# Use shared helper for focus derivation
plan_focus=$(derive_focus_from_plan "$file_path")
[[ -z "$plan_focus" ]] && plan_focus="Plan: Active work"

# Update plan_path and focus
jq --arg sid "$session_id" \
   --arg pp "$file_path" \
   --arg focus "$plan_focus" \
   '.active_sessions[$sid].plan_path = $pp |
    .active_sessions[$sid].focus = $focus' \
   "$STATUS_FILE" > "${STATUS_FILE}.tmp.$$" && mv "${STATUS_FILE}.tmp.$$" "$STATUS_FILE"

exit 0
