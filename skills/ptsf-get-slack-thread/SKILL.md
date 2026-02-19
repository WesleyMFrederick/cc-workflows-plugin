---
name: ptsf-get-slack-thread
description: Export a Slack channel or thread to a structured markdown file for ProductTank SF. Use when the user asks to "export a slack thread", "save slack messages", "archive a slack channel", "get slack thread as markdown", "document a slack conversation", or any variation of capturing Slack channel history into a readable .md file. Also trigger when the user wants to create a reference document from a Slack channel for event coordination, speaker planning, or organizer discussions.
---

# Export Slack Channel/Thread to Markdown

Fetch messages from a ProductTank SF Slack channel or thread and produce a well-structured markdown file with YAML frontmatter, key decisions summary, and full message data.

## When to Use

Whenever the user wants to capture a Slack channel or thread as a markdown reference file. Common scenarios: archiving event coordination channels, documenting speaker planning discussions, preserving decision history for retrospectives, or creating context files for other skills to consume.

## Workflow

### Step 1: Identify the Channel or Thread

Accept input in any of these forms:
- Channel name (e.g., "#organizers-26-02-25-vanessa-cribl")
- Channel ID (e.g., "C0A1XLFQZLJ")
- Slack URL (extract channel ID and optional thread_ts)
- Description (e.g., "the February event channel") and search for it

Use `channels_list` to find the channel if only a name or description is provided.

### Step 2: Fetch Messages

1. Use `conversations_history` with the channel ID to get all messages
2. For each message with a `thread_ts` (indicating it has replies), use `conversations_replies` to fetch the full thread
3. Collect all messages including threaded replies

### Step 3: Identify Participants

For each unique user in the messages, collect:
- user_id
- user_name
- real_name
- role (infer from message content and context, e.g., "Event Manager", "Speaker Manager")

Known PTSF organizer roles to look for:
- Event Manager
- Speaker Manager
- Venue Manager / F&B Manager
- AV Manager
- Social Media Manager
- MC
- Volunteer Organizer
- Closer
- MeetUp page lead

### Step 4: Extract Key Information

Scan the messages to identify:
- **Current DRI Assignments**: Who owns what role for this event
- **Key Decisions**: Date locks, venue confirmations, speaker selections, format choices
- **Open Items**: Unresolved questions, pending decisions, action items
- **Event Details**: Date, speaker, venue, topic/theme

### Step 5: Build the Markdown File

Use the structure in `references/output-format.md` as the template. The file has three sections:

1. **YAML Frontmatter**: Metadata about the channel, event, participants
2. **Summary Section**: DRI assignments, key decisions, open items
3. **Full Thread Data**: Complete JSON of all messages with threads nested

### Step 6: Save and Deliver

Save the file to the workspace folder with a descriptive name following this pattern:
`slack-{channel_name_short}-{export_date}.md`

Example: `slack-organizers-26-02-25-vanessa-cribl.md`

## Output Rules

- Include ALL messages, not just summaries. The full message data is the primary value.
- Preserve user_id mentions as-is (e.g., "U07KCG0C97C") in the raw data. In the summary sections, resolve them to real names where known.
- Include reaction data (emoji:count format)
- Thread replies should be nested inside their parent message in the JSON
- Timestamps in ISO 8601 format
- Channel name should include the # prefix in display contexts
