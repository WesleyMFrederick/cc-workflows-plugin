---
name: team-orchestration
description: Use when coordinating multiple persistent agents via TeamCreate for implementation tasks with code review - provides the complete workflow for team creation, task decomposition with dependencies, message-driven routing, fix loops, and shutdown sequence while enforcing pure delegation where orchestrator never does implementation work
---

# Team Orchestration

## Overview

Coordinate persistent agents via TeamCreate + SendMessage for implementation tasks with code review and delegated commits.

**Core principle:** Orchestrator is a pure dispatcher — creates team, creates tasks, spawns agents, routes messages, reports results. ALL implementation work (coding, reviewing, committing, investigating) is delegated to agents.

**vs. other execution skills:**
- **subagent-driven-development** — Fresh subagent per task, same session, no persistent agents
- **executing-plans** — Batch execution with human review checkpoints
- **team-orchestration** (this) — Persistent agents, message-driven routing, inter-agent communication

## When to Use

- User says "use a team" or "spawn agents" or "coordinate agents"
- Task needs agents that communicate with each other (coder ↔ reviewer)
- Multiple specialized roles needed (coder, reviewer, committer)
- Want message-driven coordination rather than subagent dispatch-and-collect

**When NOT to use:**
- Single-agent tasks → dispatch with Agent tool directly
- Independent tasks, no inter-agent communication → use `subagent-driven-development`
- Need human review between batches → use `executing-plans`

## The Workflow

```text
1. READ SPEC       — Read context ONCE to write task descriptions
2. CREATE TEAM     — TeamCreate with name + description
3. CREATE TASKS    — TaskCreate × N with blockedBy dependencies
4. SPAWN AGENTS    — Agent tool for each role (coder, reviewer)
5. ROUTE MESSAGES  — Branch on agent verdicts (APPROVED / FIX_REQUIRED)
6. SHUTDOWN        — SendMessage type: shutdown_request to all agents
7. CLEANUP         — TeamDelete
8. REPORT          — Text output to user: commit SHA, summary, verdict
```

## Task Decomposition

**Always create commit as a separate task:**

```text
Task #1: Implement (RED→GREEN)     — coder
Task #2: Review                    — reviewer, blockedBy: [1]
Task #3: Commit via /commit skill  — coder, blockedBy: [2]
```

Dependencies auto-unblock via TaskUpdate. Orchestrator doesn't manually sequence.

**Commit is a TASK, not orchestrator work.** Coder uses `/commit` skill which handles staging, diff analysis, and commit message generation.

## Orchestrator's Only Jobs

| DO | DON'T |
|----|-------|
| Read spec ONCE for task descriptions | Re-read code after delegation |
| Create team + tasks with dependencies | Run git commands (diff, add, commit) |
| Spawn agents with clear prompts | Inspect code or verify boundaries |
| Route messages based on verdicts | Stage files or write commit messages |
| Shutdown agents when done | Duplicate reviewer's work |
| Report results to user | Investigate or "quick check" anything |

**Front-load context into task descriptions** — if you know file paths, function signatures, and locations from your initial spec read, include them in the task prompt. This reduces agent ramp-up time without violating delegation (you're describing the task, not doing it).

## Message-Driven Routing

Every agent-to-orchestrator boundary crossing is a **SendMessage**. Orchestrator decisions are message-driven — route based on reports, don't investigate:

```text
Coder   → "Task #1 done, 5/5 tests pass"         → Unblock review (task #2)
Reviewer → "APPROVED"                              → Tell coder to commit (task #3)
Reviewer → "FIX_REQUIRED: {details}"               → Route fix request to coder
Coder   → "Committed: abc123 'feat: add X'"        → Shutdown + report
```

**When reviewer disagrees with spec:** Route the conflict BACK to the reviewer with specific evidence. Don't read files yourself to arbitrate.

## Fix Loop

```text
Reviewer returns → APPROVED? ─── yes ──→ Task #3 (coder commits)
                        │
                        no (FIX_REQUIRED)
                        │
                  ┌─ Message coder: "Fix {issues}"
                  ├─ Coder fixes → messages back
                  ├─ Message reviewer: "Re-review"
                  ├─ Reviewer re-reviews → messages back
                  └─ Max 2 cycles, then:
                        │
                  ┌─────┴─────┐
                  │           │
            Non-trivial    Trivial failure
            failure        (agent confusion,
                           typo, careless)
                  │           │
            Escalate      Spawn FRESH agent
            to user       with specific
                          instructions
```

**Fix loop nuance:** "Max 2 cycles → escalate" prevents infinite loops. But when the failure is clearly agent confusion (not a hard problem), spawning a fresh agent with hyper-specific instructions is pragmatic delegation — not a protocol violation. Reserve user escalation for genuine blockers.

## Shutdown Sequence

```text
1. SendMessage type: shutdown_request → coder
2. SendMessage type: shutdown_request → reviewer
3. (Wait for shutdown confirmations)
4. TeamDelete → cleans up team config + task list
5. Text output → user: commit SHA, summary, verdict
```

**Always shut down ALL agents before TeamDelete.** TeamDelete fails with active members.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|---|---|
| Orchestrator reads diff after delegation | Duplicates reviewer's work, wastes context |
| Orchestrator runs `git add` / `git commit` | Implementation work — delegate to coder with /commit |
| Orchestrator re-verifies code quality | Reviewer already verified — trust the verdict |
| No commit task in task list | Commit is work — needs a task for delegation |
| Orchestrator reads spec to override reviewer | Unilateral investigation — route conflict to reviewer instead |
| Orchestrator fixes "trivial" issue directly | Erosion starts with "just this once" — delegate everything |

## Red Flags — STOP and Reconsider

If you catch yourself doing ANY of these as orchestrator:

- Running `git diff`, `git add`, `git commit`, `git status`
- Reading source files after agents were spawned
- Verifying code changes yourself ("just a quick check")
- Writing commit messages
- Running tests yourself
- Reading spec to arbitrate a reviewer finding
- Fixing a "trivial" issue directly

**All mean: You're doing agent work. Delegate it.**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Quick git status check" | That's agent work. Trust their reports. |
| "Just verify the boundary" | Reviewer verified it. Trust the verdict. |
| "I'll commit, it's faster" | Speed ≠ correct. Coder commits via /commit skill. |
| "I already saw the diff (muscle memory)" | Sunk cost. Don't act on accidental information — route it. |
| "I have full context, spawning agent wastes time" | Front-load context into task description. Don't bypass delegation. |
| "It's a 3-character fix" | No carve-out for trivial. Delegate or it erodes the model. |
| "I remember the spec says X" | Route your memory as evidence to the reviewer. Don't investigate. |
| "Escalating a typo to user is embarrassing" | Precise escalation with actionable context is professional. Or spawn fresh agent. |
