---
description: "Create git commit using your `create-git-commit-skill`
argument-hint: "<feature-branch-name>"
---

# Execute Tasks
Create git commit using your `create-git-commit-skill`

## Input Validation

- IF $1 is NOT empty:
  - Respond with: "Creating commit for $1 branch"
- ELSE IF $1 is empty:
  - Respond with: "Warning: No feature branch provided. Committing to current branch"

<feature-branch-name>
Arguments: $1
</feature-branch-name>

## Load Skill & Execute Plan
1. Create a sub-task using the `github-assistant` agent
2. Instruct agent to load `create-git-commit-skill`
3. Instruct agent to commit branch defined during ## Input Validation
