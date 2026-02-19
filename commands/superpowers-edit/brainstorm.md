---
description: "Use when creating or developing anything, before writing code or implementation plans - refines rough ideas into fully-formed designs through structured Socratic questioning, alternative exploration, and incremental validation "
argument-hint: "<requirements-file-path> (Optional) <user-story> (Optional)"
---

# Brainstorm Design Plan
Use your your `brainstorming` skill, making sure to ground the design in the **optional** requirements-file-path argument: $1 and optional userstory: $2

## Input Validation

If path is provided ($1 is populated), respond with: "Brainstorm skill initiated using $2 to ground the design discussion"

<task-paths-input>
Arguments: $1 $2
</task-paths-input>

## Load Skill & Execute Plan
1. Load `brainstorming` skill
2. If requirements-file-path argument provided, read @$1
3. If provided, Focus on user story $2
4. Gather additional context

   ```bash
   citation-manager extract links $1
   ```

5. Use steps 2-4 to ground your design discussion
