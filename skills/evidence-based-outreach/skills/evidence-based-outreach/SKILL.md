---
name: evidence-based-outreach
description: >
  Use when the user asks to "draft an outreach email", "write a networking email",
  "reply to an intro", "draft a cold email", or any professional email where claims
  need evidence backing. Provides a deciban-scored claim audit workflow with
  evidence tracing, iterative refinement, and Obsidian-compatible evidence files.
version: 0.1.0
---

# Evidence-Based Outreach

Draft professional emails where every claim is scored against evidence. Produce auditable, traceable correspondence that projects credibility without overclaiming.

## Core Principle

Every sentence in an outreach email makes implicit claims. Score each claim against actual evidence. Hedge where evidence is thin. Strengthen weak claims with targeted research, or cut them.

## Workflow Phases

### Phase 1: Clarify

Confirm before starting:
- **Recipient** — who, what role, what company
- **Goal** — what outcome does the email seek (meeting, intro, follow-up)
- **Source material** — original thread (email/Slack), prior conversations, uploaded evidence files
- **User's relationship** — how they know this person, shared context
- **Constraints** — tone, things to avoid, timing

### Phase 2: Gather Evidence

Save all source material to the working folder as evidence files.

**Evidence file format** — use Obsidian-compatible markdown with `^block-id` refs on key lines:

```markdown
# Source: [type] - [description]

**From:** ...
**Date:** ...
**Link:** [original URL if available]

---

Key statement from source material ^claim-anchor
Another traceable statement ^another-anchor
```

Block IDs enable the claim audit to link directly to source lines: `[evidence-file.md#^claim-anchor](evidence-file.md#^claim-anchor)`

### Phase 3: Research

Spawn a research subagent (Task tool) for shallow research on:
- The person (role, background, recent activity)
- Their company/product (what it does, market position, recent news)
- Domain-specific context that strengthens weak claims

Write research to a `*-research.md` file in the working folder. Add `^block-id` refs to key findings so the claim audit can trace to them.

### Phase 4: Approach

Present the proposed approach before drafting. Cover:
- **Tone** — match the register of the source thread
- **Structure** — what goes in, what stays out
- **Key claims** — what the email will assert and approximate evidence strength
- **What to save for in-person** — insights too nuanced for email

Get explicit user confirmation. Use AskUserQuestion if needed.

### Phase 5: Draft + Claim Audit

Write email and claim audit to a single markdown file:

```markdown
# Reply Draft v1 — Re: [Subject]

## Email

**To:** ...
**Subject:** ...

---

[email body]

---

## Claim Audit

| # | Claim | dB | Evidence Type | Evidence Source | Evidence Trace |
|---|-------|----|---------------|----------------|----------------|
| 1 | "exact words from email" | **N** | [type from scale] | [source description] | [obsidian link to evidence] |
```

See `references/deciban-scale.md` for the scoring framework.

### Phase 6: Review Loop

1. User opens the markdown file and adds comments (highlights, strikethroughs, inline notes)
2. Read the file — parse all user annotations
3. Incorporate changes, update claim scores, do additional research if user flags a claim as weak
4. Write updated version to the same file (bump version header)
5. Repeat until user says **"lock"**

## Drafting Rules

- **No em dashes.** Dead giveaway for AI-written text. Use commas or periods.
- **No claims beyond evidence.** If you researched something, you can reference it. If you didn't, don't imply you did.
- **Hedge proportionally.** Claims at 3 dB need "it sounds like" or "from that one conversation." Claims at 7+ can be stated directly.
- **Mirror the source register.** If the intro email is casual ("cheers"), match it. If formal, match that.
- **Front-load value.** The recipient should know why this email matters in the first two sentences.
- **Keep it short.** Intro reply emails should be under 100 words. Momentum dies in long emails.

## Output Style

Use CEO-scannable formatting for all chat responses:
- Front-load decisions in the first sentence
- Use tables over prose for comparisons
- Progressive disclosure: brief first, detail on request
- No hedge words ("basically", "essentially", "actually")
- No narrative filler about what you did or why

## References

- **`references/deciban-scale.md`** — Full evidence scoring framework, hedging rules by score, claim strengthening strategies
- **`references/obsidian-linking.md`** — Block refs, cross-document links, evidence file templates for email/Slack/research sources
- **`references/user-comments.md`** — How to parse Obsidian highlights, strikethroughs, score corrections, and research requests during the review loop
