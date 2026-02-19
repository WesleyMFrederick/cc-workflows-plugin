---
name: set-plan
description: Manually register any file as the active plan for session tracking
arguments:
  - name: path
    description: Path to the plan file (absolute or relative)
    required: true
---

# Set Active Plan

Register the specified file as this session's active plan in `current-status.json`.

## CRITICAL: Implementation Rules

- **USE the Edit tool** to update `current-status.json`. Two targeted edits: one for `plan_path`, one for `focus`.
- **DO NOT** use Bash, jq, cat, echo, or any shell command to modify the file.
- **DO NOT** create temporary files, pipes, or redirects.
- **DO NOT** rewrite the entire JSON — only edit the two fields for this session.
- **Read the file first** with the Read tool, then Edit the specific field values.

## Steps

1. **Validate** file exists at `$ARGUMENTS` path (use `ls` via Bash)
2. **Resolve** to absolute path if relative (use `realpath` via Bash)
3. **Extract H1 title** from first 5 lines of the file (use Read tool, find `#` line)
4. **Detect plan type** from filename:
   - Contains `whiteboard` → `Discovery:`
   - Contains `prd` or `requirements` → `Requirements:`
   - Contains `design` → `Design:`
   - Contains `sequencing` → `Sequence:`
   - Contains `implement` → `Implement:`
   - Default → `Plan:`
5. **Read** `current-status.json` with the Read tool
6. **Edit** `plan_path` value for this session's entry using the Edit tool
7. **Edit** `focus` value for this session's entry using the Edit tool (set to `"{Type} {H1 title}"`)
8. **Confirm** with: `✓ Plan registered: {focus}`

## Example

Input: `/set-plan tools/citation-manager/design-docs/features/20251119-type-contract-restoration/typescript-migration-sequencing.md`

Result — two Edit tool calls targeting this session in `current-status.json`:
- `plan_path` → `"/Users/.../typescript-migration-sequencing.md"`
- `focus` → `"Sequence: TypeScript Migration - Sequencing"`
