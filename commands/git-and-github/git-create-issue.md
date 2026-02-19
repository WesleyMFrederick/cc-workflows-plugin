---
description: Create a GitHub issue with proper labels
argument-hint: "<title> (Optional) <feature> (Optional) <component> (Optional) <priority> (Optional)"
---

# Create Issue

Use the `managing-github-issues-skill` to create an issue.

## Input

<arguments>
- $1: Issue title
- $2: Feature name (e.g., citation-manager)
- $3: Component name in PascalCase (e.g., CitationValidator)
- $4: Priority level (low | medium | high)
</arguments>

## Execute

1. Load `managing-github-issues-skill` skill
2. If $1 provided: Use as issue title
3. If $2 provided: Add `feature: $2` label
4. If $3 provided: Add `component:$3` label
5. If $4 provided: Add `priority:$4` label
6. For missing required labels, prompt user
7. Create issue with proper formatting
