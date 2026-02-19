# Slack Export Output Format

The exported markdown file follows this exact structure. Every section is required unless marked optional.

## Structure

```markdown
---
source: slack
channel_id: {{channel_id}}
channel_name: "#{{channel_name}}"
event: ProductTank SF - {{Month Year}}
event_date: {{YYYY-MM-DD}}
speaker: {{Speaker Name}}
talk_title: {{Talk Title or Topic}}
venue: {{Venue Name}}
description: {{1-2 sentence description of what this channel covers}}
summary: "{{3-5 sentence summary of key activity, decisions made, and current status}}"
participants:
  - name: {{Real Name}}
    user_id: {{Uxxxxxxxxxx}}
    user_name: {{slack_username}}
    role: {{Role(s) for this event}}
member_count: {{number}}
message_count: {{number}}
thread_count: {{number of messages that have replies}}
date_range:
  first: {{YYYY-MM-DD}}
  last: {{YYYY-MM-DD}}
exported: {{YYYY-MM-DD}}
---

# Slack: #{{channel_name}}

## Current DRI Assignments (as of {{latest_date}})

| Role | Owner |
|------|-------|
| Event Manager | {{Name}} |
| Sponsorship/Funding Manager | {{Name}} |
| F&B Manager | {{Name}} ({{Company}}) |
| Venue Manager | {{Name}} ({{Company}}) |
| AV Manager | {{Name}} |
| YouTube Video | {{Name or TBD}} |
| Speaker Manager | {{Name}} |
| Volunteer Organizer | {{Name}} |
| Social Media Manager | {{Name}} |
| MC | {{Name}} |
| Closer | {{Name}} |

## Key Decisions

- **{{Topic}}**: {{Decision and context}}
- **{{Topic}}**: {{Decision and context}}

## Open Items

1. {{Description of unresolved item}} ({{date of last mention}})
2. {{Description of unresolved item}}

## Full Thread Data

```json
{
  "channel_id": "{{channel_id}}",
  "channel_name": "#{{channel_name}}",
  "member_count": {{number}},
  "fetched_at": "{{ISO 8601 timestamp}}",
  "message_count": {{number}},
  "thread_count": {{number}},
  "messages": [
    {
      "msg_id": "{{message timestamp}}",
      "user_id": "{{Uxxxxxxxxxx}}",
      "user_name": "{{slack_username}}",
      "real_name": "{{Display Name}}",
      "channel": "{{channel_id}}",
      "thread_ts": "{{parent timestamp if this starts a thread, empty if not}}",
      "text": "{{message text with user mentions as raw IDs}}",
      "time": "{{ISO 8601}}",
      "reactions": "{{emoji:count|emoji:count or empty}}",
      "replies": [
        {
          "msg_id": "{{timestamp}}",
          "user_id": "{{Uxxxxxxxxxx}}",
          "user_name": "{{slack_username}}",
          "real_name": "{{Display Name}}",
          "text": "{{reply text}}",
          "time": "{{ISO 8601}}",
          "reactions": "{{emoji:count or empty}}"
        }
      ]
    }
  ]
}
```
```

## Field Notes

### Participants

- List only people who actually posted in the channel
- Infer roles from message content, DRI assignment posts, and context
- A person can have multiple roles (comma-separated)
- For external/guest users whose real names don't resolve, use the user_id as-is and note in the description

### Summary

- Write as a quoted string in YAML (use double quotes)
- Cover: when channel was created, what the event is, key milestones, current status
- Keep to 3-5 sentences

### Messages

- Include ALL messages chronologically
- Thread replies nest inside the parent message's `replies` array
- Messages that start threads have `thread_ts` equal to their own `msg_id`
- Messages without threads have `thread_ts` as empty string
- Preserve raw user mentions (e.g., "U07KCG0C97C") in the message text
- Reactions format: `emoji_name:count` separated by `|` (e.g., "+1:2|heart:1")
- Include skin tone modifiers in reaction names if present (e.g., "+1::skin-tone-3:1")

### DRI Assignments

- Pull from the most recent DRI status message in the channel
- If no explicit DRI post exists, infer from context (who volunteered for what)
- Mark unassigned roles as "TBD"

### Key Decisions

- Bold the topic/category
- Include enough context that someone reading the export can understand the decision without reading all messages
- Focus on decisions that are final or have consensus

### Open Items

- Include date of last discussion for each item
- Order by importance/urgency
