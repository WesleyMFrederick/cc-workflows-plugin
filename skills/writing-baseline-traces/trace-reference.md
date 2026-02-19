# Sound Trace Reference

Full trace example from `extract-verbose-flag/baseline.md` — the gold standard for evidence-tagged traces in this project.

## What Makes This Trace Sound

1. **Every step has an evidence tag** with file:line
2. **Boundary crossings** are explicit (HOOK → CLI → RETURN)
3. **Sub-steps** (6a-6e) model what happens inside the called component
4. **Key lines** are called out where the interesting behavior lives
5. **F-INF conclusions** cite specific step numbers they derive from

## Full Trace

```text
TRACE: extractor hook (PostToolUse:Read)
══════════════════════════════════════════

 HOOK TRIGGER
 ─────────────
 1. [C: Claude Code runtime]
    Event: PostToolUse:Read fires
    Matcher: "Read" → extractor.sh

 HOOK: GUARDS
 ────────────
 2. [O: extractor.sh:27-30]
    Guard: jq available?
    FAIL → exit 0 (silent skip)

 3. [O: extractor.sh:34-45]
    Resolve: citation-manager binary
    Try: local build (dist/citation-manager.js)
    Fallback: global CLI
    FAIL → exit 0 (silent skip)

 4. [O: extractor.sh:56-63]
    Parse: stdin JSON from Claude Code
    Extract: file_path, session_id
    FAIL (no file_path) → exit 0

 5. [O: extractor.sh:77-80]
    Guard: file_path ends in .md?
    FAIL → exit 0 (silent skip)

 HOOK → CLI (boundary crossing)
 ──────────────────────────────
 6. [O: extractor.sh:92]
    CALL ──→ citation-manager extract links "$file_path" --session "$session_id"
    │
    │  CLI: PARSE ARGS
    │  ────────────────
    │  6a. [O: citation-manager.ts:1131-1291]
    │      Commander.js parses: extract links <file> --session <id>
    │
    │  CLI: ORCHESTRATE
    │  ────────────────
    │  6b. [O: citation-manager.ts:429-480]
    │      extractLinks() → validate links → extract content
    │
    │  CLI: EXTRACT + DEDUPLICATE
    │  ──────────────────────────
    │  6c. [O: ContentExtractor.ts:88-235]
    │      Strategy chain → content extraction → SHA-256 dedup
    │
    │  CLI: OUTPUT
    │  ───────────
    │  6d. [O: citation-manager.ts:466]
    │      console.log(JSON.stringify(result, null, 2))
    │      ├── extractedContentBlocks  (50KB)  [M]
    │      ├── outgoingLinksReport     (44KB)  [M]
    │      └── stats                   (124B)  [M]
    │      TOTAL: 94KB to stdout               [M]
    │
    │  6e. [O: citation-manager.ts:exit codes]
    │      Exit: 0 (success) | 1 (no content) | 2 (error)
    │
    RETURN ←── stdout (94KB JSON) + exit code
    │

 HOOK: PROCESS CLI OUTPUT
 ────────────────────────
 7. [O: extractor.sh:93]
    Capture: exit code from CLI

 8. [O: extractor.sh:97-106]
    Branch on exit code:
    ├── 0 + empty output → exit 0 (cache hit, already extracted)
    ├── 1             → exit 0 (no citations found)
    └── 2 or empty    → exit 0 (error, silent)

 9. [O: extractor.sh:109]                         ← KEY LINE
    Parse: jq '.extractedContentBlocks'
    USES:    50KB (content blocks)
    DISCARDS: 44KB (outgoingLinksReport) + 124B (stats)
    WASTE:   46% of received data                  [M: 44KB / 94KB]

10. [O: extractor.sh:112-116]
    Guard: extracted content not null/empty?
    FAIL → exit 0

11. [O: extractor.sh:121]                         ← KEY LINE
    Transform: jq maps content blocks →
    "## Citation: <contentId>\n\n<content>\n---"

    INPUT FORMAT:  JSON (extractedContentBlocks object)
    OUTPUT FORMAT: markdown text (flat string)

 HOOK: EMIT RESULT
 ─────────────────
12. [O: extractor.sh:132-139]
    Wrap: jq builds hookSpecificOutput JSON envelope
    {
      "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": "<formatted markdown>"
      }
    }

13. [O: extractor.sh:141]
    Output: JSON to stdout → Claude Code injects as additionalContext

14. [O: extractor.sh:144]
    Exit: 0 (always non-blocking)

══════════════════════════════════════════
END TRACE
```

## F-INF Derivations From This Trace

These show how sound inferred facts cite specific steps:

1. **[F-INF: from steps 6d + 9]** The hook receives 94KB but uses only 50KB. The 44KB (46%) is **pipe waste, not context waste** — the CLI serializes it, the pipe transmits it, and the hook immediately discards it via `jq '.extractedContentBlocks'`. Claude never sees the `outgoingLinksReport`.

2. **[F-INF: from steps 9 + 11]** The hook performs two format transformations: JSON → extracted blocks (jq) → markdown text (jq). The final output to Claude is markdown, not JSON.

3. **[F-INF: from step 6d]** The CLI's `console.log(JSON.stringify(result, null, 2))` is the single output point. Any change to default output format affects ALL consumers simultaneously.

4. **[F-INF: from steps 2-5]** The hook has 4 guard clauses that exit silently (exit 0). Any of these failing means no content injection.

## Why Each F-INF Is Sound

| F-INF | Cites | Derivation is valid because |
|-------|-------|---------------------------|
| #1 | steps 6d + 9 | 6d measures total output (94KB); 9 shows jq filter discards report (44KB). Math checks out. |
| #2 | steps 9 + 11 | 9 shows jq extracts JSON blocks; 11 shows jq maps to markdown. Two transformations, verified. |
| #3 | step 6d | 6d shows single `console.log` call. One output point = all consumers get same format. |
| #4 | steps 2-5 | Four sequential guards, each with `exit 0` on failure. Count matches. |