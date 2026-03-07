# Evidence-Based Outreach

Draft professional outreach emails with deciban-scored claim audits. Every claim is traced to evidence, scored for confidence, and iteratively refined through user review.

## Components

| Component | Name | Purpose |
|-----------|------|---------|
| Command | `/draft-outreach` | Kick off the evidence-based email workflow |
| Skill | evidence-based-outreach | Domain knowledge: deciban scale, claim auditing, evidence tracing, Obsidian linking, review loop |

## Usage

1. Run `/draft-outreach [goal or context]` to start
2. Provide source material (email thread, Slack thread, evidence files)
3. Review the draft + claim audit in the generated markdown file
4. Add comments/highlights in the file, then tell Claude to incorporate
5. Repeat until satisfied, then say "lock"

## What It Produces

For each outreach email, the plugin creates a folder with:
- **Evidence file(s)** — source threads saved with Obsidian `^block-id` refs
- **Research file** — shallow research on person/company with traceable findings
- **Draft file** — email text + claim audit table with dB scores and evidence traces

## The Deciban Scale

Each claim gets a 1-10 dB score based on evidence quality, from "base model knowledge" (1) to "live system state" (10). See `skills/evidence-based-outreach/references/deciban-scale.md` for the full scale.
