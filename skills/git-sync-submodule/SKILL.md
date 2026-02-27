---
name: git-sync-submodule
description: Use when .claude submodule is behind the local hub and needs to catch up - discovers remotes dynamically, detects divergence, safety-checks content loss, and moves submodule pointer to match hub HEAD
---

# Sync Submodule to Local Hub

## Overview

**Catch-up workflow for when `.claude` submodule is behind its local hub.** Discovers remotes dynamically, classifies divergence, safety-checks for content loss, and moves the submodule pointer — or STOPS and presents options when conflict exists.

**Core Principle:** Never hardcode remote names. Never move the pointer without proving no content is lost.

**Cross-reference:** The reverse direction (dirty submodule -> push TO hub) is handled by `git-create-commit-skill` Submodule Propagation. Do not duplicate that workflow here.

## When to Use

- Parent repo's `.claude` submodule is behind the hub
- After editing skills directly in `cc-workflows-plugin` hub
- When `git status` shows `.claude` has "new commits" from upstream
- After another consumer pushed changes to the hub

**Not for:** Dirty submodule with uncommitted local changes (use `git-create-commit-skill` instead).

## 8-Step Process

Execute in order. Do NOT skip steps.

### Step 1: Discover Remotes

```bash
git -C .claude remote -v
```

Identify the local hub remote (path-based URL, often `origin-local` or `origin`). **Never hardcode the remote name.**

### Step 2: Fetch from Hub

```bash
git -C .claude fetch <hub-remote>
```

### Step 3: Compare HEADs

```bash
git -C .claude log --oneline -1 HEAD
git -C .claude log --oneline -1 <hub-remote>/main
```

If HEADs are identical: **Already synced. Stop.**

### Step 4: Classify Divergence

```bash
git -C .claude log --oneline --graph <hub-remote>/main...HEAD
```

| Pattern | Classification | Action |
|---------|---------------|--------|
| Hub ahead, submodule behind (linear) | **Catch-up** | Proceed to Step 6 |
| Both have unique commits, no overlap | **Diverged-safe** | Proceed to Step 5 |
| Both have unique commits, overlapping files | **Diverged-conflict** | Proceed to Step 5 |
| Submodule ahead of hub | **Submodule-ahead** | Use `git-create-commit-skill` to push instead |

### Step 5: Safety Check (diverged paths only)

Find the merge base, then diff overlapping files:

```bash
git -C .claude merge-base HEAD <hub-remote>/main
git -C .claude diff <merge-base>..HEAD --stat
git -C .claude diff <merge-base>..<hub-remote>/main --stat
```

For each overlapping file:

```bash
git -C .claude diff HEAD <hub-remote>/main -- <file>
```

- **Empty diff on all overlapping files:** Submodule commits are a subset. Safe to proceed to Step 6.
- **Non-empty diff (real conflict):** **STOP.** Present options:

> **Divergence detected with conflicting changes.**
>
> 1. **Rebase submodule onto hub** — `git -C .claude pull --rebase <remote> main` (preserves local commits on top of hub)
> 2. **Discard submodule-only commits** — move pointer to hub HEAD (loses local-only changes)
> 3. **Abort** — leave submodule as-is, investigate manually
>
> Which option?

Do NOT proceed without user choice.

### Step 6: Move Pointer

```bash
git -C .claude checkout <hub-remote>/main
```

Expected: detached HEAD state (normal for submodules).

### Step 7: Verify Alignment

```bash
git -C .claude log <hub-remote>/main..HEAD --oneline
```

Must be empty. If not, something went wrong — investigate.

### Step 8: Commit Parent

Stage and commit the pointer update in the parent repo using `git-create-commit-skill` format:

```text
chore(deps): update .claude submodule with <summary of hub changes>
```

## Red Flags — STOP Immediately

- "Remote is always `origin`" — WRONG. Discover dynamically (Step 1).
- "No need to fetch, I can just checkout" — WRONG. Must fetch first (Step 2).
- "HEADs differ, just move the pointer" — WRONG. Must classify divergence (Step 4).
- "Overlapping files probably don't conflict" — WRONG. Diff proves it (Step 5).
- "I'll rebase automatically to save time" — WRONG. User chooses on conflict (Step 5).
- "Detached HEAD means something broke" — WRONG. Expected for submodules (Step 6).

## Evidence

Traced workflow: [submodule-sync-workflow.md](../../../design-docs/workflows/submodule-sync-workflow.md)
