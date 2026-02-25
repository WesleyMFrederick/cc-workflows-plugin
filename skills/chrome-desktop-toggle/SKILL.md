---
name: chrome-desktop-toggle
description: Use when switching Chrome browser control between Claude Desktop and Claude Code, when Chrome extension isn't connecting, or when "native messaging host" conflicts occur. Triggers on "toggle chrome", "switch chrome to code", "switch chrome to desktop", "chrome extension not working", "chrome native messaging".
---

# Chrome Desktop Toggle

## Problem

Claude Desktop and Claude Code both register native messaging hosts for the same Chrome extension ID (`fcoeoabgfenejglbffodgkkbkcdhcgfn`). Chrome picks Desktop's host first (alphabetical ordering), locking Claude Code out. This skill toggles Desktop's host file to switch Chrome control between the two tools.

## Host Files

```text
~/Library/Application Support/Google/Chrome/NativeMessagingHosts/
  com.anthropic.claude_browser_extension.json       → Desktop (toggle target)
  com.anthropic.claude_code_browser_extension.json  → Code (untouched)
```

## Commands

### Check current state

```bash
ls "/Users/wesleyfrederick/Library/Application Support/Google/Chrome/NativeMessagingHosts/" | grep claude
```

- If `com.anthropic.claude_browser_extension.json` exists → Desktop is **enabled** (Desktop gets Chrome)
- If `com.anthropic.claude_browser_extension.json.disabled` exists → Desktop is **disabled** (Code gets Chrome)

### Disable Desktop (give Chrome to Claude Code)

```bash
mv "/Users/wesleyfrederick/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_browser_extension.json" "/Users/wesleyfrederick/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_browser_extension.json.disabled"
```

### Enable Desktop (give Chrome to Claude Desktop)

```bash
mv "/Users/wesleyfrederick/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_browser_extension.json.disabled" "/Users/wesleyfrederick/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_browser_extension.json"
```

## Workflow

1. **Check state** — run the `ls` command to see which mode is active
2. **Toggle** — run the appropriate `mv` command
3. **Verify** — run `ls` again to confirm the rename took effect
4. **Restart Chrome** — the user must fully quit and reopen Chrome for the change to take effect

## Important

- **Always check state first** before toggling — running the wrong `mv` will error if the source file doesn't exist
- **Chrome must be restarted** after toggling — the native messaging host is read at browser startup
- **Never modify or delete** `com.anthropic.claude_code_browser_extension.json` — that's Code's own host file
- If both `.json` and `.json.disabled` variants exist for Desktop, something went wrong — only one should exist at a time
