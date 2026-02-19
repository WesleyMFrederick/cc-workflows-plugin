#!/bin/bash

# Verification Script: Dynamic Logging Location for Tested Skills
# Related: GitHub Issue #11, User Story 2.3
# Purpose: Verify test logs are colocated with tested skill, not in testing-skills-with-subagents

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
TESTING_SKILL_DIR="$REPO_ROOT/.claude/skills/testing-skills-with-subagents"
LOGS_DIR="$TESTING_SKILL_DIR/logs"

echo "🔍 Verifying dynamic logging location fix..."
echo ""

# Check if any logs exist in the centralized testing-skills-with-subagents/logs directory
if [ -d "$LOGS_DIR" ]; then
  log_count=$(find "$LOGS_DIR" -type f -name "*.log" 2>/dev/null | wc -l)

  if [ "$log_count" -gt 0 ]; then
    echo "❌ FAILED: Found $log_count log files in centralized location:"
    echo "   Location: $LOGS_DIR"
    echo ""
    echo "   Logs should be colocated with tested skill instead."
    echo "   Example: .claude/skills/{skill-name}/logs/YYYYMMDD-HHMMSS-test-session/"
    echo ""
    find "$LOGS_DIR" -type f -name "*.log" | head -5
    exit 1
  fi
fi

# Check if any skills have logs in their own directories (expected behavior)
skills_with_logs=0
for skill_dir in "$REPO_ROOT/.claude/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  if [ -d "$skill_dir/logs" ]; then
    log_count=$(find "$skill_dir/logs" -type f -name "*.log" 2>/dev/null | wc -l)
    if [ "$log_count" -gt 0 ]; then
      skills_with_logs=$((skills_with_logs + 1))
      echo "✅ Found colocated logs in: $skill_name"
      echo "   Path: $skill_dir/logs"
      echo "   Files: $log_count log file(s)"
      echo ""
    fi
  fi
done

if [ "$skills_with_logs" -eq 0 ]; then
  echo "⚠️  WARNING: No test logs found in any skill directories"
  echo "   This is expected if no tests have been run yet."
  echo ""
  echo "   Once Story 2.3 is implemented, run:"
  echo "   → testing-skills-with-subagents skill"
  echo "   → Fast variant"
  echo "   → Test a skill (e.g., citation-manager)"
  echo ""
  echo "   Then logs should appear in:"
  echo "   → .claude/skills/{skill-name}/logs/YYYYMMDD-HHMMSS-test-session/"
  exit 0
fi

echo "✅ SUCCESS: Logging location is correctly colocalized with tested skills"
exit 0
