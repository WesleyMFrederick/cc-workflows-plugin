---
description: Draft an outreach email with evidence-backed claim auditing
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch, Task, TodoWrite, AskUserQuestion
argument-hint: [goal or context]
---

Start the evidence-based outreach workflow for: $ARGUMENTS

Load the evidence-based-outreach skill, then follow its phases in order:

1. **Clarify** — Confirm who the email is to, the goal, and what evidence exists (threads, prior conversations, uploaded files). Use AskUserQuestion if unclear.
2. **Gather** — Read source material (emails, Slack threads, evidence files). Save to an evidence file with Obsidian `^block-id` refs.
3. **Research** — Do shallow research on the person/company. Write findings to a research file in the working folder.
4. **Approach** — Suggest tone, structure, what to include/exclude. Get user confirmation before drafting.
5. **Draft + Audit** — Write the email and claim audit table to a single markdown file. Every claim gets a dB score with evidence trace.
6. **Review loop** — User comments in the markdown file. Read comments, incorporate, update claims. Repeat until user says "lock."

Use the CEO-scannable output style for all chat responses. Front-load decisions, no narrative filler.
