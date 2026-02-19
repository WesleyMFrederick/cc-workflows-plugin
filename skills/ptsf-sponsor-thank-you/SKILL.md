---
name: ptsf-sponsor-thank-you
description: Draft and track end-of-year sponsor/venue thank you emails for ProductTank SF. Use when the user asks to "send sponsor thank yous", "thank venues", "draft sponsor notes", "thank our hosts", or any variation of creating year-end appreciation emails to PTSF venue sponsors, F&B sponsors, or in-kind sponsors. Also trigger when the user mentions PRO-194 or end-of-year sponsor follow-up. Covers venue-only, F&B-only, venue+F&B, and mixed sponsorship types.
---

# Sponsor Thank You Email Workflow

Draft personalized thank you emails for ProductTank SF venue and F&B sponsors, and track them in Linear. This is an iterative workflow: generate drafts, user sends them, then re-run to detect sent emails, update Linear, and generate remaining drafts.

## Gmail Account

- **From:** wmfrederick+producttanksf@gmail.com
- **CC all drafts:** Jerry Young <jerryjyoung@gmail.com>, karsh.pandey@gmail.com, emargulies@gmail.com, melissahsu2016@gmail.com

## Data Sources

| Source | What to Find | How to Access |
|--------|--------------|---------------|
| **Master Event Spreadsheet** | Venue companies, contacts, F&B sponsors, YouTube URLs | `gsheets_read` spreadsheetId: `1RnNx_kF0YsaiG2VlcgMO1oVs56rjKBIxtQKjVsvwq2o` sheet: "Next Events" |
| **Linear PRO-194** | Tracking issue for sponsor thank yous | `get_issue` id: `PRO-194` |
| **Gmail** | Previously sent thank you emails | `search_gmail_messages` with `q: "from:wmfrederick+producttanksf@gmail.com subject:(ProductTank SF Thanks) in:sent"` |

## Spreadsheet Columns (Next Events sheet)

| Data | Column |
|------|--------|
| Date, Year | A, B |
| YouTube Title, URL | H, I |
| Venue Company | Q |
| Venue Sponsor Contact First Name | AC |
| Venue Sponsor Contact Email | AD |
| Venue Space Logistics Contact First Name | AE |
| Venue Space Logistics Contact Email | AF |
| Venue Space Logistics Other First Names | AG |
| Venue Space Logistics Other Emails | AH |
| F&B Sponsor Company | AI |
| F&B Sponsor First Name | AJ |

Read `references/email-template.md` for the full template, grouping logic, and sponsor classification rules.

## Workflow

### Step 1: Check Current State

1. Read Linear PRO-194 for current status table
2. Search Gmail for sent emails: `from:wmfrederick+producttanksf@gmail.com subject:(ProductTank SF Thanks) in:sent`
3. Read spreadsheet for sponsor data

### Step 2: Update Linear with Sent Emails

For each sent email not yet tracked in Linear:
1. Add comment to PRO-194 with email content (see format in references)
2. Update description table status to "Sent"

### Step 3: Generate Remaining Drafts

For sponsors with status "Not sent" and valid contacts:
1. Group all events by sponsor company
2. Classify sponsorship type (venue-only, F&B-only, venue+F&B, mixed)
3. Apply the correct email template based on event count and type
4. Output formatted draft in chat
5. Wait for user to send, then re-run

### Step 4: Report Status

```
**PRO-194 Status:** X/Y sent, Z blocked

| Sponsor | Type | Events | Contact | Status |
|---------|------|--------|---------|--------|
| Neon | Venue only | Jul, Aug | Teddy | Sent |
| Cribl | Venue + F&B | Sep, Feb | Glen, Casey | Draft ready |
| VAPI | F&B only | Aug, Oct | Dan | Missing email |
```

## Output Rules

- No em dashes anywhere. Use commas, periods, or "and" instead.
- To, CC, Subject each on its own line with blank line between
- Present drafts in final display style
- The user sends manually; do not attempt to send via Gmail API
