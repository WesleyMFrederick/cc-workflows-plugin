#!/bin/bash
# Shared status sync helpers - sourced by hooks

# Scan task files for in_progress task
# Sets: TASK_NUMBER, TASK_SUMMARY, TASKS_DIR
scan_tasks() {
  local session_id="$1"
  TASKS_DIR="$HOME/.claude/tasks/$session_id"
  TASK_NUMBER=""
  TASK_SUMMARY=""

  [[ ! -d "$TASKS_DIR" ]] && return 0

  for task_file in "$TASKS_DIR"/*.json; do
    [[ -f "$task_file" ]] || continue
    local status=$(jq -r '.status // ""' "$task_file" 2>/dev/null)
    if [[ "$status" == "in_progress" ]]; then
      TASK_NUMBER=$(jq -r '.id // ""' "$task_file" 2>/dev/null)
      local active_form=$(jq -r '.activeForm // ""' "$task_file" 2>/dev/null)
      TASK_SUMMARY="Task #${TASK_NUMBER}: ${active_form}"
      break
    fi
  done
}

# Resolve task header from plan file
# Args: plan_path, task_number
# Returns: header text or empty
resolve_task_header() {
  local plan_path="$1"
  local task_number="$2"

  [[ -z "$plan_path" || ! -f "$plan_path" || -z "$task_number" ]] && return
  grep -m1 "^### .*${task_number}[:.)]" "$plan_path" 2>/dev/null || echo ""
}

# Detect plan type from file path (maps to development workflow phases)
# Returns: "Discovery:", "Requirements:", "Design:", "Sequence:", "Implement:", or "Plan:" default
detect_plan_type() {
  local file_path="$1"

  # Phase 1: Discovery & Ideation
  if [[ "$file_path" =~ whiteboard ]]; then
    echo "Discovery:"
  # Phase 1 output: Requirements/PRD
  elif [[ "$file_path" =~ (prd|requirements) ]]; then
    echo "Requirements:"
  # Phase 2: Research & Design
  elif [[ "$file_path" =~ design ]]; then
    echo "Design:"
  # Phase 3: Sequencing
  elif [[ "$file_path" =~ sequencing ]]; then
    echo "Sequence:"
  # Phase 4: Implementation
  elif [[ "$file_path" =~ implement ]]; then
    echo "Implement:"
  # Claude Code plans (default)
  else
    echo "Plan:"
  fi
}

# Derive focus from plan H1 header
# Args: plan_path
# Returns: "{Type}: {H1 title}" or empty
derive_focus_from_plan() {
  local plan_path="$1"

  [[ -z "$plan_path" || ! -f "$plan_path" ]] && return

  local type_prefix=$(detect_plan_type "$plan_path")
  local title=$(head -5 "$plan_path" | grep -m1 "^# " | sed 's/^# //' || echo "")
  [[ -z "$title" ]] && title="Active work"

  echo "${type_prefix} ${title}"
}
