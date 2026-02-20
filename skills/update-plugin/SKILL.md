# Update Plugin Skill

Use when the user says "update plugin", "update .claude", or "pull latest skills" — pulls the latest cc-workflows-plugin into the project's `.claude` submodule and commits the pointer update.

## Steps

1. Run the update script:
   ```bash
   .claude/skills/update-plugin/scripts/update-submodule.sh
   ```

2. Verify the submodule was updated:
   ```bash
   git submodule status
   ```
   Confirm the hash has changed from the previous value.

3. Report what changed:
   ```bash
   git -C .claude log --oneline -10
   ```
   Summarize the new commits pulled in.
