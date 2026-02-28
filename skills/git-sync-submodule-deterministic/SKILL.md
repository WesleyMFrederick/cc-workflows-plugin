---
name: git-sync-submodule-deterministic
description: Deterministic submodule sync — script handles Steps 1-7 mechanics, LLM only parses output and handles semantics (commit message, conflict options)
---

# Sync Submodule to Local Hub (Deterministic)

## Step 1: Run Script

```bash
.claude/skills/git-sync-submodule-deterministic/scripts/sync-submodule.sh .claude main
```

Parse stdout KEY=VALUE pairs. Stderr has phase markers (informational only).

## Step 2: Handle Result by STATUS

### `STATUS=synced` (exit 0)
Report: "Already synced at `OLD_HEAD`." Done.

### `STATUS=catch-up` or `STATUS=diverged-safe` (exit 0)
Proceed to Step 3 (commit parent).

### `STATUS=conflict` (exit 2)
**STOP. Present these 3 options to user:**

> **Divergence detected with conflicting changes.**
> Overlapping files: `OVERLAP_FILES`
> Details: `DIFF_SUMMARY`
>
> 1. **Rebase submodule onto hub** — `git -C .claude pull --rebase <HUB_REMOTE> main`
> 2. **Discard submodule-only commits** — move pointer to hub HEAD
> 3. **Abort** — leave as-is, investigate manually

Do NOT proceed without user choice.

### `STATUS=submodule-ahead` (exit 3)
Report: "Submodule is ahead of hub — use `git-create-commit-skill` to push instead." Done.

### `STATUS=error` (exit 1)
Report the `ERROR` value. Do NOT retry blindly.

## Step 3: Commit Parent

Stage and commit pointer update in parent repo using `git-create-commit-skill` format:

```text
chore(deps): update .claude submodule with <summary of hub changes>
```

## Red Flags — STOP Immediately

- Running `git -C .claude remote/fetch/checkout/log` manually — WRONG. Script handles Steps 1-7.
- Retrying script after `STATUS=error` without investigating — WRONG.
- Proceeding past `STATUS=conflict` without user choice — WRONG.
- Hardcoding remote name in conflict resolution — WRONG. Use `HUB_REMOTE` from script output.

## Evidence

Based on: [git-sync-submodule SKILL.md](../git-sync-submodule/SKILL.md)
Pattern: [setup-worktree.sh](../../scripts/setup-worktree.sh) — "script handles mechanics, LLM handles semantics"
