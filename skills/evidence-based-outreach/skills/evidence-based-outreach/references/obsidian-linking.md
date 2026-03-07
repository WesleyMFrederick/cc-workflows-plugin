# Obsidian Cross-Document Linking

Reference for creating traceable evidence files that work in Obsidian vaults.

## Block References

Add `^block-id` at the end of any line to make it linkable:

```markdown
FDA requires audit trails for all electronic records. ^fda-audit-req
```

Rules:
- Block IDs must be lowercase, hyphens allowed, no spaces
- Place at end of line after a space
- One block ID per line
- Use descriptive IDs: `^fda-part11` not `^ref1`

## Cross-Document Links

### Markdown-style (works everywhere, preferred for claim audit tables)
```markdown
[filename.md#^block-id](filename.md#^block-id)
```

### Wikilink-style (Obsidian-native, shorter)
```markdown
[[filename#^block-id]]
```

### Header links
```markdown
[filename.md#Header Name](filename.md#Header%20Name)
[[filename#Header Name]]
```

## Evidence File Structure

Every evidence file should include:

1. **YAML frontmatter** with source metadata (type, date, participants, links)
2. **Summary section** for quick scanning
3. **Full content** with `^block-id` on every claimable statement
4. **Source links** (URLs, Gmail links, Slack thread URLs)

### Example: Email evidence file

```markdown
# Gmail: [Subject Line]

**From:** Name <email>
**To:** Name <email>
**Date:** YYYY-MM-DD
**Gmail Link:** [Open in Gmail](url)

---

Please meet my friend and colleague Ed Martin ^intro

He has compelling insights into AI-driven development ^ai-context

Maybe the next ProductTank event? ^meeting-suggestion
```

### Example: Slack evidence file

```markdown
---
source: slack
channel_name: "#channel"
thread_url: https://slack.url
---

# Slack: #channel - [Topic]

## Thread Summary
[2-3 sentence summary]

## Key Messages

Jorge shared a product update with demo video ^jorge-update

Wesley responded noting improvements since October ^wesley-response
```

### Example: Research evidence file

```markdown
# [Person/Company] — Research

## [Person Name]
- **Title:** ... ^person-title
- **Background:** ... ^person-background

## [Product/Company]
- **What:** ... ^product-description
- **FDA:** ... ^fda-status

## Key Findings
IEC 62304 allows lighter processes for Class A components ^risk-classification
```

## Linking in Claim Audit Tables

The Evidence Trace column uses cross-document links:

```markdown
| # | Claim | dB | Evidence Type | Evidence Source | Evidence Trace |
|---|-------|----|---------------|----------------|----------------|
| 3 | "talked in December" | **7** | Cross-referenced verified | User context + Gmail | [gmail-intro.md#^intro](gmail-intro.md#^intro) |
| 5 | "audit trail the FDA demands" | **5** | Verified + research | User + research | [research.md#^fda-part11](research.md#^fda-part11), [research.md#^iec62304](research.md#^iec62304) |
```

Comma-separate multiple traces. Each trace should resolve to a specific line in an evidence file.
