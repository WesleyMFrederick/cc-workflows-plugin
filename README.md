# cc-workflows-plugin

Claude Code plugin — skills, hooks, settings, and commands for Claude Code sessions.

This repo is designed to be added as a **`.claude` submodule** in any project. When Claude Code opens a project with `.claude/` populated from this repo, it automatically loads all skills, hooks, and settings.

## Architecture: Local Hub-and-Spoke

```
cc-workflows-plugin (LOCAL HUB)
  ├── origin: local path (fast, no network)
  ├── github: GitHub URL (backup only)
  │
  ├── jact/.claude → pulls/pushes here
  └── other-project/.claude → pulls/pushes here
```

**Remotes in each consumer's `.claude/` submodule:**
- `origin` → `/Users/wesleyfrederick/Documents/ObsidianVault/0_SoftwareDevelopment/cc-workflows-plugin`
- `github` → `https://github.com/WesleyMFrederick/cc-workflows-plugin.git`

## Quick Start: Add to a new project

```bash
# From your project root:
git submodule add /Users/wesleyfrederick/Documents/ObsidianVault/0_SoftwareDevelopment/cc-workflows-plugin .claude

# Rewire remotes (origin = local hub, github = backup)
git -C .claude remote rename origin origin-local
git -C .claude remote add origin /Users/wesleyfrederick/Documents/ObsidianVault/0_SoftwareDevelopment/cc-workflows-plugin
git -C .claude remote add github https://github.com/WesleyMFrederick/cc-workflows-plugin.git
git -C .claude branch --set-upstream-to=origin/main main

git commit -m "feat: add cc-workflows-plugin as .claude submodule"
```

Then add this to your `package.json` scripts so submodule content is restored on every `npm install`:

```json
"postinstall": "git submodule update --init --recursive"
```

## Existing clones / first-time setup

If you cloned a project that uses this plugin but `.claude/` is empty:

```bash
git submodule update --init --recursive
```

## Day-to-Day Workflow

### Making changes to skills/commands/hooks

```bash
# 1. Commit inside submodule
git -C .claude add -A
git -C .claude commit -m "fix(scope): description"

# 2. Push to local hub
git -C .claude push origin main

# 3. Commit pointer in parent
git add .claude
git commit -m "chore(deps): update .claude submodule"
```

### Pulling latest into a project

```bash
git -C .claude pull origin main
git add .claude
git commit -m "chore(deps): update .claude submodule to latest"
```

### Backing up to GitHub

```bash
git -C .claude push github main
```

## Contents

- `.claude/skills/` — reusable skill prompts loaded by Claude Code
- `.claude/hooks/` — PostToolUse and PreToolUse hooks (citation validator, extractor, linter)
- `.claude/settings.json` — Claude Code settings (tool permissions, hook paths)
- `.claude/commands/` — slash commands
