---
description: "Sync .claude submodule to match the local hub"
---

# Execute Tasks

Sync .claude submodule to match the local hub.

## Skill Selection

If `$ARGUMENTS` contains "deterministic" (e.g., `/git-sync-submodule deterministic`):
- Use `git-sync-submodule-deterministic` skill (script-driven, fewer tokens)

Otherwise (default):
- Use `git-sync-submodule` skill (LLM-driven 8-step process)

## Load Skill & Execute Plan
1. Create a sub-task using the `github-assistant` agent
2. Instruct agent to load the selected skill (see above)
3. Instruct agent to execute the sync process per that skill
