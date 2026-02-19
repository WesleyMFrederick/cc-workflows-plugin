---
name: updating-claude-code
description: Use when updating, downgrading, or checking Claude Code CLI version - provides npm commands for version management with Seatbelt sandbox wrapper compatibility. Triggers on "upgrade claude", "downgrade claude", "pin claude version", "check claude version".
---

# Updating Claude Code

## Architecture

```text
~/.local/bin/claude      → wrapper (Seatbelt sandbox)
/opt/homebrew/bin/claude → real binary (npm-global)
```

Version changes via npm only. Wrapper auto-uses whatever npm installed.

## Pre-flight (MANDATORY)

Before any version operation, verify the seatbelt wrapper is installed:

```bash
which claude
# MUST show: ~/.local/bin/claude
# If it shows /opt/homebrew/bin/claude → wrapper is MISSING
```

**If wrapper is missing**, install it first:

```bash
./packages/sandbox/install-claude-wrapper.sh
```

Then re-verify with `which -a claude` — wrapper must appear before `/opt/homebrew/bin/claude`.

**DO NOT proceed with version changes until wrapper is confirmed.**

## Commands

### Check version

```bash
/opt/homebrew/bin/claude --version
```

### Upgrade to latest

```bash
npm i -g @anthropic-ai/claude-code@latest
```

### Pin specific version

```bash
npm i -g @anthropic-ai/claude-code@2.1.21
```

### List available versions

```bash
npm view @anthropic-ai/claude-code versions --json | tail
```

### Verify

```bash
which -a claude  # wrapper first, then /opt/homebrew/bin
```

## Important

- **DO NOT use `claude update`** - use npm
- Auto-updater disabled for stability
- `claude doctor` warning about "native" is expected

## Troubleshooting

Version mismatch? Check: `which claude` and `readlink ~/.local/bin/claude`

Install wrapper: `./packages/sandbox/install-claude-wrapper.sh`

Full docs: `packages/sandbox/README.md`
