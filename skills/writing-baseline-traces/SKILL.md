---
name: writing-baseline-traces
description: Use when writing baseline traces in OpenSpec documents - provides trace format, process tree definitions, hard gates for trace subject confirmation, and a gold standard example. For evidence tag rules and verification, see the verifying-evidence skill.
---

# Writing Baseline Traces

## Overview

Baseline documents record the factual state of the current system through **traces** (literal execution records) and optionally **process trees** (abstracted workflow models). This skill covers the format and discipline for writing these structures. For evidence tag rules, verification checklists, and the [A]/[Q] utility format, see the `verifying-evidence` skill.

## Key Definitions

**Trace** = Literal execution record. This is the **evidence layer**. Each step is numbered and tagged with `[O: file:line]` or `[M: command → result]`. Boundary crossings between components are explicit (e.g., `HOOK → CLI`, `RETURN ←──`). A trace records what ACTUALLY HAPPENED in a specific execution path.

**Process Tree** = Abstracted workflow model derived FROM traces. This is the **inference layer**, tagged with `[F-INF]`. Uses operators (→ sequential, × exclusive choice, ∧ parallel, ↻ redo loop) to describe POSSIBLE paths — not a single execution. Every branch must reference the trace step(s) that evidence it.

**Write traces first. Derive process trees from them.** You cannot model structure until you have recorded evidence. A baseline may have only traces if the workflow is purely linear.

## Hard Gates

These are mandatory checkpoints. Do NOT proceed past them without user confirmation.

1. **Trace Subject Confirmation**: Before reading source files or writing trace content, STOP and ask the user: "What system/format should I trace?" Present candidates from the whiteboard and let the user choose. Do not speculatively read source files in parallel.

## One-Shot: Sound Trace (condensed)

Every step tagged, boundary crossings explicit, F-INF cites step numbers:

```text
TRACE: extractor hook (PostToolUse:Read)
═══════════════════════════════════════

 3. [O: extractor.sh:34-45]
    Resolve: jact binary
    FAIL → exit 0 (silent skip)

 HOOK → CLI (boundary crossing)
 ──────────────────────────────
 6. [O: extractor.sh:92]
    CALL ──→ jact extract links "$file_path"
    │
    │  6d. [O: jact.ts:466]
    │      console.log(JSON.stringify(result, null, 2))
    │      ├── extractedContentBlocks  (50KB)  [M]
    │      ├── outgoingLinksReport     (44KB)  [M]
    │      └── TOTAL: 94KB to stdout           [M]
    │
    RETURN ←── stdout (94KB JSON) + exit code

 9. [O: extractor.sh:109]                    ← KEY LINE
    Parse: jq '.extractedContentBlocks'
    DISCARDS: 44KB (46%)                      [M: 44KB / 94KB]

═══════════════════════════════════════
```

**Sound F-INF from this trace:**
> [F-INF: from steps 6d + 9] The hook receives 94KB but uses only 50KB. The 44KB is pipe waste — CLI serializes it, hook discards via jq.

For the complete 14-step trace with all F-INF derivations, see [trace-reference.md](trace-reference.md).

## Trace-Specific Red Flags — STOP and Fix

- Process tree with untagged steps
- "Trace" that uses → × ∧ ↻ operators instead of numbered [O]/[M]-tagged steps (this is a process tree mislabeled as a trace)
- Process tree with no [F-INF] references back to trace steps
