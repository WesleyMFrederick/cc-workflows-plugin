---
name: verifying-evidence
description: Use when writing or reviewing any OpenSpec artifact to verify every claim is evidence-tagged, properly sourced, and logically sound using the full 13-tag Evidence Ontology ([OBS], [M], [F-ID], [F-LK], [E], [H], [A], [C], [O], [G], [Q], [P], [D]). Catches untagged claims, vague citations, misclassified tags, broken derivation chains, and tag-strengthening failures. Applies to baseline, ideal, delta, and all downstream artifacts.
---

# Verifying Evidence

## Overview

Evidence discipline applies to every artifact in the OpenSpec workflow — not just baselines. **A claim without an evidence tag is an ungrounded assertion.** This skill provides the full 13-tag Evidence Ontology, verification checklist, common failure patterns, and the Baseline/Ideal/Delta bucket framework to ensure every factual claim is tagged, every tag has valid evidence, and every derivation chain is traceable.

This skill uses the full 13-tag Evidence Ontology. Key changes from the original 7-tag taxonomy:
- `[OBS: file:line]` replaces the old `[O: file:line]` for observation pointers
- `[F-ID]` and `[F-LK]` replace `[F-INF]` (structural vs empirical split)
- `[O]` now means Outcome (stable end state), not Observation
- New tags: `[E]` Evidence, `[H]` Hypothesis, `[G]` Goal, `[P]` Priority

## When to Use

- Writing any OpenSpec artifact (baseline, ideal, delta, proposal, specs, design)
- Reviewing an artifact before proceeding to the next
- After editing an artifact — re-verify affected sections
- When classifying inputs into Baseline / Ideal / Delta buckets

## Evidence Tag Requirements

Each tag type has specific evidence requirements. A claim with the wrong tag or insufficient evidence is **unsound**.

| Tag | Requires | Valid Source Example | Invalid Source Example |
|-----|----------|--------------------|-----------------------|
| **[OBS]** Observation | file:line in THIS codebase | `[OBS: extractor.sh:109]` | `[OBS: Node fetch behavior]` — no file:line pointer |
| **[M]** Measured | reproduction command + result | `[M: wc -c → 94,231 bytes]` | `[M: about 94KB]` — no command, approximate value |
| **[F-ID]** Fact-Identified | cites specific [OBS]/[M] it derives from; P=1.0 | `[F-ID: from steps 4+9]` | `[F-ID: because it makes sense]` — no cited evidence |
| **[F-LK]** Fact-Locked | empirical-but-frozen, cites source | `[F-LK: DB size = 4TB as of 2026-02]` | `[F-LK: the system is fast]` — no measurement, no source |
| **[E]** Evidence | observation + source that updates a hypothesis | `[E: trace step 7 contradicts H-1]` | `[E: I think this disproves it]` — no observation pointer |
| **[H]** Hypothesis | mutable claim about reality, testable | `[H: the hook silently drops large payloads]` | `[H: we should use streaming]` — that is a [D]ecision |
| **[A]** Assumed | states what is unknown/untested | `[A: LLM ignores metadata — not verified]` | (no invalid form — honesty is valid) |
| **[C]** Constraint | immutable external requirement | `[C: jq required by hook runtime]` | `[C: retry must not add latency]` — this is a design [D]ecision |
| **[O]** Outcome | stable end state; passes three disqualifiers | `[O: all citations resolve on first read]` | `[O: migrate from JSON to YAML]` — has from/to language (too low-level) |
| **[G]** Goal | directional intent / strategic motivation | `[G: reduce context waste below 10%]` | `[G: run jq on output]` — that is an implementation step, not strategic intent |
| **[Q]** Question | labeled uncertainty about current system | `[Q: does header extract use same path?]` | `[Q: what output format should we use?]` — design choice, belongs in Ideal Bucket |
| **[P]** Priority | relative importance or ordering | `[P: resolve Q-1 before designing delta]` | `[P: this is important]` — no relative ranking or ordering |
| **[D]** Decision | explicit resource commitment | `[D: use --verbose flag for debugging]` | `[D: the API requires JSON]` — if you can't choose otherwise, it's [C] |

### Critical Distinctions

**[OBS] vs [A]:** If you didn't read the specific file:line in THIS codebase, it's [A], not [OBS]. General knowledge about how Node.js or libraries work is [A] unless you verified it in the actual source.

**Secondhand information is [A]:** If someone TOLD you "line 142 uses fetch()", that's [A] until YOU read line 142. Don't invent new tag variants like `[M: provided by context]` — the taxonomy is fixed. Use `[A: reported — not independently verified]` and note the source.

**[F-ID] vs [F-LK]:**
- `[F-ID]` = Structural/logical derivation. Necessarily true given the evidence. P=1.0. Example: "The hook has 4 guard clauses" (you counted them in the trace).
- `[F-LK]` = Empirical-but-frozen fact. Contingently true, treated as fixed for this analysis. Example: "Current DB size = 4TB" (measured, but could change tomorrow).
- **Test:** If you could derive it from the trace steps alone using logic/math, it's `[F-ID]`. If you'd need to re-measure to confirm it's still true, it's `[F-LK]`.

**[C] vs [D]:** Constraints are things you CANNOT change (external APIs, runtime behavior, hook format requirements). If you COULD choose differently, it's a [D]ecision, not a [C]onstraint. Test: "Could a different team reasonably make a different choice here?" If yes, it is [D].

**[O] Outcome meaning:** [O] is a stable end state, NOT an observation pointer. Must pass three disqualifiers — no from/to language, no condition clauses, no tool/data references. If any appear, you are one level too low. Use [OBS] for observation pointers.

**[H] vs [A]:** Both express uncertainty, but they serve different functions. [H] is a testable claim about reality — it predicts something you can verify. [A] is an acknowledged gap — it states what you do not know. A hypothesis can be wrong; an assumption is honest about not knowing.

### [H] and [A] Strengthening Loop

Evidence tags are not static labels. Hypotheses and assumptions have defined paths to stronger tags:

**[H] Hypothesis strengthening via [E] Evidence:**
- [H] starts as a mutable claim about how reality works
- [E] is gathered — an observation + source that directly updates the hypothesis
- Accumulating [E] either strengthens [H] toward [F-LK] (empirically confirmed) or refutes [H] (discard or revise)
- Path: `[H] → gather [E] → [F-LK]` (confirmed) or `[H] → gather [E] → revised [H]` (refuted)

**[A] Assumption strengthening via verification:**
- [A] starts as an acknowledged unknown
- Verification (reading code, running commands) produces [OBS] or [M] evidence
- That evidence either promotes [A] to [F-ID]/[F-LK] or reveals the assumption was wrong
- Path: `[A] → verify → [OBS]/[M] → derive [F-ID]` (structural) or `[A] → verify → [M] → [F-LK]` (empirical)

**Why this matters:** Knowing the strengthening path tells you what verification action to take. For [H], gather evidence. For [A], go read the code or run the command.

### [A] and [Q] Sub-Line Format

Every [A] and [Q] in an artifact must include sub-lines that assess the value of resolving them. This prevents the default instinct of "verify everything" when the artifact already has sufficient evidence to proceed.

**For [A] (Assumptions):**

```
- **To strengthen → [F-ID]/[F-LK]:** [what verification steps would look like]
- **Utility of strengthening:** [honest cost/benefit — does this unlock the next artifact or will implementation surface it faster?]
```

**For [Q] (Open Questions):**

```
- **Verification plan:** [concrete steps to answer]
- **Utility of answering:** [low/moderate/high for baseline vs. design — does resolving this change understanding of the current system, or is it a design choice?]
```

**Why:** An artifact with sufficient evidence should proceed to the next stage. Polishing [A] to [F-ID] that doesn't change downstream decisions is wasted effort.

### Writing Mode vs Verify Mode

**When writing an artifact:** Tag as you go. The key discipline is honesty about what you actually observed. If you READ a file, tag it [OBS]. If you RAN a command and got output, tag it [M]. If you derived a conclusion from cited evidence using logic/math, tag it [F-ID]. If it is an empirical fact you are freezing for this analysis, tag it [F-LK]. If you are forming a testable claim, tag it [H]. If you are working from someone else's notes or context, tag it [A]. Promote to stronger tags only after you personally verify.

**When verifying an artifact:** Run the 4-pass checklist below. Every finding gets a specific fix recommendation.

## Buckets: Baseline, Ideal, Delta

Buckets represent **system states**, not ontology types; any evidence tag can exist in any bucket.

- **Baseline (Current State)**
  *Definition:* The system as it exists today.
  *Key question:* Where are we now?
  *Purpose:* Understand reality and constraints before change.

- **Ideal (Target State)**
  *Definition:* The future system if everything worked perfectly.
  *Key question:* What would success look like if fully achieved?
  *Purpose:* Define evaluation criteria and aspirational outcomes.

- **Delta (Transformation Path)**
  *Definition:* Candidate ways to move from baseline to ideal.
  *Key question:* What changes could move us toward the ideal?
  *Purpose:* Decision-making and planning.

### Baseline-Ideal-Delta Logic

When baseline and ideal can be expressed using the same units or frameworks, the **delta** becomes the transformation that bridges baseline to ideal. If baseline and ideal are not directly comparable, first translate them into a shared framework before deriving the delta.

### Entry Point Adaptation

Clients may engage at different starting points. Regardless of entry, reconstruct the baseline, ideal, and delta before deciding on a path forward.

| Client Entry | First Action |
|---|---|
| Baseline problem | Map the current baseline → infer a feasible ideal |
| Ideal vision | Clarify the ideal → map the baseline |
| Solution idea | Treat the idea as part of the delta → reconstruct ideal & baseline |
| Metrics gap | Map the metrics → infer the ideal |
| Constraints | Map constraints → define a feasible ideal |
| Mixed inputs | Decompose inputs into ontology elements → bucket appropriately |

> **Core Rule:** Always reconstruct all three buckets — baseline, ideal, and delta — before committing to decisions.

## Verification Checklist

Run this pass on every artifact. Go section by section.

### Pass 1: Tag Completeness

Scan every sentence that makes a factual claim. Ask: "Does this have an evidence tag?"

**What counts as a claim:**
- Any statement about how the system works today
- Any number, size, count, percentage
- Any statement about what code does
- Any assertion about behavior, flow, or output
- Any prediction or testable hypothesis
- Any statement about priorities or ordering

**What does NOT need a tag:**
- Section headers
- Template boilerplate (blockquote metadata, horizontal rules)
- Markdown comments
- Reproduction commands inside code blocks (the measurement itself is tagged, not the command)

### Pass 2: Tag Correctness

For each tagged claim, verify the tag matches the evidence type:

1. **Every [OBS]** — Does it cite a specific file:line in this codebase? Not a concept, not a library, not general knowledge.
2. **Every [M]** — Does it include a reproduction command (or reference to one in the Measurements section)? Is the actual measured value stated?
3. **Every [F-ID]** — Does it explicitly cite which [OBS] or [M] evidence it derives from? Is the derivation structural/logical with P=1.0? Can you trace the chain?
4. **Every [F-LK]** — Does it cite a source? Is it an empirical fact being frozen for analysis, not a structural derivation?
5. **Every [E]** — Does it include both an observation and a source? Does it reference a specific [H] it updates?
6. **Every [H]** — Is it testable? Is it a claim about reality, not a design choice?
7. **Every [A]** — Good. Honest uncertainty is the correct tag for unverified claims. Does it include sub-lines?
8. **Every [C]** — Is this truly immutable? Apply the "could another team choose differently?" test. If yes, it is [D].
9. **Every [O]** — Does it pass the three disqualifiers (no from/to language, no condition clauses, no tool/data references)?
10. **Every [G]** — Is it directional/strategic, not an implementation step?
11. **Every [Q]** — Is it about the current system, not a design choice? Does it include sub-lines?
12. **Every [P]** — Does it express relative ranking or ordering, not just "this is important"?
13. **Every [D]** — Is it a genuine choice? If there is no alternative, it is [C].

### Pass 3: Derivation Chain Integrity

For each [F-ID] and [F-LK]:
1. Find the cited source evidence
2. Verify the source evidence actually exists in the document
3. Verify the inference logically follows from the cited evidence
4. Check for missing intermediate steps

For each [E]:
1. Verify the observation pointer exists
2. Verify it references a specific [H]
3. Verify the evidence actually updates the hypothesis (supports, contradicts, or refines)

**Broken chain example:**
> [F-ID: from step 6d] Compact output would save tokens

This jumps from "CLI outputs 94KB" to "compact output saves tokens" without establishing what "compact" means or how token count relates to byte count. Missing intermediate: what gets removed, and how does removal affect token count?

### Pass 4: Open Questions and Hypothesis Audit

- "No open questions" in an artifact is a **red flag**. Most artifacts surface unknowns.
- Check: Are any [A] assumptions actually [Q] questions that should be resolved before the next artifact?
- Check: Are any [H] hypotheses actually [A] assumptions (not testable) or [D] decisions (choices, not reality claims)?
- Check: Are there ??? markers anywhere that should be in Open Questions?
- **Scope check**: [Q]s are structural unknowns about the CURRENT system — does resolving this change understanding of how the system works TODAY? If yes, keep as [Q]. If no (it is a design choice about what to build), move it to the Ideal Bucket instead.
- **Strengthening check**: For each [H], is there a plausible [E]-gathering plan? For each [A], is there a plausible verification plan? If not, note the gap.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "The tag type is close enough" | Wrong tag = misleading evidence strength. [OBS] vs [A] is the difference between verified and guessed. |
| "Everyone knows how fetch() works" | General knowledge is [A]. Only code you READ in THIS repo is [OBS]. |
| "Context says line 142 uses fetch()" | Secondhand info is [A]. Promote to [OBS] only after you read line 142 yourself. |
| "I'll create a custom tag for this" | The taxonomy is fixed at 13 tags. No `[M: provided by context]` or `[OBS: assumed]`. Use [A] with a source note. |
| "The measurement is approximately right" | [M] requires a reproduction command. "About 94KB" is [A]. `wc -c → 94,231 bytes` is [M]. |
| "The constraint is obvious" | If you could choose differently, it is [D]. Constraints are immutable. |
| "F-ID follows logically" | Logical is not the same as cited. [F-ID] must reference specific evidence, not appeal to reasoning. |
| "F-LK is basically the same as F-ID" | [F-ID] is structural (P=1.0, necessarily true). [F-LK] is empirical (contingently true, frozen). Different evidence strength. |
| "This hypothesis is obviously true" | If it is obviously true, gather [E] and promote it to [F-LK]. Until then, it is still [H]. |
| "No open questions — this is straightforward" | Most artifacts surface unknowns. Zero questions means you stopped looking. |
| "This outcome needs conditions" | If it has condition clauses, from/to language, or tool references, it is not an [O]utcome — it is too low-level. |
| "Everything is high priority" | [P] requires relative ranking. If everything is P1, nothing is prioritized. |
| "Time pressure — we need to move on" | A weak artifact makes every downstream artifact wrong. 15 min verification saves hours of rework. |

## Red Flags — STOP and Fix

- Claim without any evidence tag
- [OBS] citing "behavior" or "how X works" instead of file:line
- [M] without reproduction command
- [F-ID] without explicit derivation reference to [OBS]/[M] steps
- [F-LK] without a source or measurement date
- [E] without both an observation pointer and a hypothesis reference
- [H] that is actually a design decision (use [D]) or an untestable claim (use [A])
- [C] that fails the "could another team choose differently?" test
- [O] with from/to language, condition clauses, or tool/data references
- [G] that describes an implementation step instead of strategic intent
- [Q] that is a design choice rather than a structural unknown about the current system
- [P] that says "important" without relative ranking
- [D] where no alternative exists (should be [C])
- Empty Open Questions section
- "About", "roughly", "approximately" in measurements without actual measured value
- [H] with no plausible [E]-gathering path
- [A] with no plausible verification path to [F-ID] or [F-LK]
- Old taxonomy tags: `[O]` used as observation (use [OBS]), `[F-INF]` used anywhere (use [F-ID] or [F-LK])

## Quick Reference: Verification Output Format

When reporting verification results, use this structure:

```
## Verification: [document name]

### Tag Completeness: X untagged claims found
- [location]: "claim text" → suggested tag

### Tag Correctness: X misclassified tags found
- [location]: tagged [OBS] but source is general knowledge → should be [A]

### Derivation Chains: X broken chains found
- [F-ID-N]: cites step X but inference requires step Y (missing)

### Hypothesis & Question Audit: X issues found
- [H-N] is not testable → should be [A]
- [A-N] should be [Q] because: [reason]

### Verdict: SOUND / UNSOUND (with fix list)
```
