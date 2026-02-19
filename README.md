# cc-workflows-plugin

Claude Code plugin — skills, hooks, settings, and commands for Claude Code sessions.

This repo is designed to be added as a **`.claude` submodule** in any project. When Claude Code opens a project with `.claude/` populated from this repo, it automatically loads all skills, hooks, and settings.

## Quick Start: Add to a new project

```bash
# From your project root:
git submodule add https://github.com/WesleyMFrederick/cc-workflows-plugin.git .claude
git commit -m "feat: add cc-workflows-plugin as .claude submodule"
```

Then add this to your `package.json` scripts so teammates don't have to think about it:

```json
"postinstall": "git submodule update --init --recursive"
```

After that, `npm install` handles everything automatically.

## Existing clones / first-time setup

If you cloned a project that uses this plugin but `.claude/` is empty:

```bash
git submodule update --init --recursive
```

## Updating the plugin

```bash
cd .claude
git pull origin main
cd ..
git add .claude
git commit -m "chore: update cc-workflows-plugin"
```

## Contents

- `.claude/skills/` — reusable skill prompts loaded by Claude Code
- `.claude/hooks/` — PostToolUse and PreToolUse hooks (citation validator, extractor, linter)
- `.claude/settings.json` — Claude Code settings (tool permissions, hook paths)
- `.claude/commands/` — slash commands
