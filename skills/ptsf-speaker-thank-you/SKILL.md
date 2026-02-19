---
name: ptsf-speaker-thank-you
description: Draft and track end-of-year speaker thank you emails for ProductTank SF. Use when the user asks to "send speaker thank yous", "draft speaker thank you notes", "thank speakers for the year", or any variation of creating year-end appreciation emails to PTSF speakers. Also trigger when the user mentions PRO-190 or end-of-year speaker follow-up. Covers both email drafting and Linear tracking via PRO-190.
---

# Speaker Thank You Email Workflow

Draft personalized thank you emails for ProductTank SF speakers and track them in Linear. This is an iterative workflow: generate drafts, user sends them, then re-run to archive sent emails to Linear and generate remaining drafts.

## When to Use

End of year (or whenever the user wants to thank speakers from a completed year). The workflow reads speaker data from the master spreadsheet, drafts personalized emails, and tracks send status in Linear.

## Gmail Account

All drafts and sends use: `wmfrederick+producttanksf@gmail.com`

## Data Sources

| Source | What to Find | How to Access |
|--------|--------------|---------------|
| **Master Event Spreadsheet** | Speaker names, emails, event dates, venues, themes, YouTube URLs | `gsheets_read` spreadsheetId: `1RnNx_kF0YsaiG2VlcgMO1oVs56rjKBIxtQKjVsvwq2o` sheet: "Next Events" |
| **Linear PRO-190** | Tracking issue for speaker thank yous | `get_issue` id: `PRO-190` |
| **Gmail** | Previously sent thank you emails | `search_gmail_messages` with `q: "from:wmfrederick+producttanksf@gmail.com subject:(Speaking) in:sent"` |

## Spreadsheet Columns (Next Events sheet)

| Data | Column |
|------|--------|
| Date | A |
| Year | B |
| Speaker Name | C |
| Theme | D |
| YouTube Video Title | H |
| YouTube URL | I |
| Venue Company | Q |
| Speaker First Name | AA |
| Speaker Email | AB |

## Workflow

### Step 1: Gather Speaker Data

1. Read the master spreadsheet, filtering to the target year
2. For each event, extract: speaker first name, email, event month, venue, theme, video title, YouTube URL
3. Skip speakers without email addresses

### Step 2: Check Current State

1. Read Linear PRO-190 for current tracking status
2. Search Gmail for already-sent thank you emails: `from:wmfrederick+producttanksf@gmail.com subject:(Speaking {year}) in:sent`
3. Cross-reference to determine which speakers still need emails

### Step 3: Archive Sent Emails to Linear

For each sent email not yet tracked in Linear PRO-190:

1. Read the full email thread
2. Add a comment to PRO-190 using this format:

```
**To:** {{speaker_name}} <{{speaker_email}}>
**From:** {{sender_name}} <{{sender_email}}>
**CC:** {{cc_recipients, omit if none}}

**Subject:** {{subject}}

{{email_body}}
```

3. Post comments in chronological order

### Step 4: Draft Remaining Emails

For speakers who haven't received a thank you yet, output the email draft in chat.

Read `references/email-template.md` for the template and fill in all variables.

Key rules:
- If no YouTube URL exists for a speaker, omit the YouTube paragraph entirely
- Use the theme to write a 2-4 word lowercase summary for the "your talk on ___" line
- Adjust for singular/plural as needed

### Step 5: Report Status

After each run, provide a summary:

```
**PRO-190 Status:** X/Y sent

| Speaker | Month | Status |
|---------|-------|--------|
| Tom | August | Sent |
| Jorge | September | Draft ready |
| Aman | October | Missing email |
```

## Output Rules

- Present email drafts in final display style (rendered markdown, not raw)
- No em dashes anywhere in the email. Use commas, periods, or "and" instead.
- Each draft should show To, Subject, and body clearly separated
- The user will send manually; do not attempt to send via Gmail API
