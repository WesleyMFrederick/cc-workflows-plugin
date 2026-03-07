# Deciban Evidence Scale

Scoring framework for claim auditing. Each score = decibans of evidence weight; implied likelihood ratios follow directly.

## Scale

| dB | Evidence Type | LR (10^(dB/10)) | Intuition |
|----|---------------|------------------|-----------|
| 1 | Base Model Knowledge (Training Data) | 1.26:1 | Barely above noise, you'd hardly bet on it |
| 2 | Unverified User Input | 1.58:1 | Slight edge, they know their own context |
| 3 | Reasoning Chains | 2:1 | Active deduction doubles your odds vs recall |
| 4 | Non-Training Isolated Example (single artifact) | 2.5:1 | Concrete but uncorroborated |
| 5 | Verified User Input (single piece confirmed) | 3.16:1 | Claim + evidence, now "more likely than not" |
| 7 | Cross-Referenced Verified Patterns (multiple pieces) | 5:1 | Independent corroboration, big jump |
| 8 | Execution Verification | 6.3:1 | The system told you directly |
| 9 | Verified User Input + Execution | 7.9:1 | Human context + system confirmation |
| 10 | Live System State | 10:1 | Ground truth, you'd bet real money |

## Why the Gap at 6

The jump from single-source verified (5) to multi-source corroborated (7) represents the biggest qualitative shift in evidence quality: independent confirmation. The 2-deciban jump from ~3:1 to ~5:1 captures the "convergence bonus" when multiple artifacts agree.

Reserve 6 for "verified user input with partial cross-reference" if granularity is needed later.

## Composition

Stacking evidence: base training (1) + unverified user input (2) + reasoning chain (3) = 6 dB total, LR ~4:1. An LLM that recalls something, hears the user confirm it, and reasons through it should land around 4:1 odds before hard verification.

## Hedging Rules by Score

| dB Range | Hedging Required | Example Language |
|----------|-----------------|------------------|
| 1-3 | Heavy hedge | "it sounds like", "from that one conversation", "my understanding is" |
| 4-5 | Moderate hedge | "based on [source]", attribute clearly |
| 7-8 | Light or none | State directly, cite source |
| 9-10 | None | State as fact |

## Strengthening Weak Claims

When a claim scores below 5:
1. **Research** — Spawn a subagent to find independent corroboration (regulatory docs, public filings, news)
2. **Reframe** — Shift the claim from single-source interpretation to independently verifiable fact (e.g., "the risk side demands" → "the FDA process demands")
3. **Hedge** — If no corroboration exists, add appropriate hedging language
4. **Cut** — If the claim can't be strengthened or hedged, remove it

## Claim Audit Table Format

```markdown
| # | Claim | dB | Evidence Type | Evidence Source | Evidence Trace |
|---|-------|----|---------------|----------------|----------------|
```

- **Claim:** Exact quoted words from the email
- **dB:** Score from scale above, bolded
- **Evidence Type:** Description using scale terminology
- **Evidence Source:** Where the evidence lives (Gmail link, user context, research file)
- **Evidence Trace:** Obsidian cross-document link to specific block ref (see below)

## Evidence Trace Links (Obsidian Format)

Use Obsidian-compatible wikilink or markdown link syntax to trace claims to evidence:

### Within same file
```markdown
See [[#^block-id]]
```

### Cross-document (relative markdown links)
```markdown
[evidence-file.md#^block-id](evidence-file.md#^block-id)
```

### Cross-document (wikilinks, if vault uses wikilinks)
```markdown
[[evidence-file#^block-id]]
```

### Example evidence trace cell
```markdown
[sandeep-gmail-intro.md#^intro](sandeep-gmail-intro.md#^intro), [ed-martin-bruin-research.md#^fda-part11](ed-martin-bruin-research.md#^fda-part11)
```

Multiple traces can be comma-separated when a claim draws on more than one source.
