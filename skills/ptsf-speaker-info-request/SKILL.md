---
name: ptsf-speaker-info-request
description: Draft a speaker info request email for returning ProductTank SF speakers who already have a row in the Speaker Form spreadsheet. Use when the user asks to "get speaker info", "request marketing materials from a speaker", "email a returning speaker for their talk details", or any variation of collecting talk title, abstract, bio, and photo from a speaker for an upcoming PTSF event. Also trigger when the user mentions needing info for a meetUp page or promo slide for a returning speaker.
---

# Speaker Info Request for Returning Speakers

Request marketing materials from a returning ProductTank SF speaker by pulling their existing form data, identifying gaps, and drafting an email that puts the ask first and confirmation second.

## When to Use

A returning speaker already has a row in the Speaker Form Results spreadsheet from a previous event. This skill drafts an email that:
1. Asks for new event-specific content (talk title, abstract, key takeaways)
2. Includes format examples modeled on a recent strong submission
3. Presents their existing bio/photo/LinkedIn for confirmation
4. Sets a deadline tied to the event calendar

This is NOT for brand-new speakers who have never submitted the form. For those, direct them to the speaker intake form.

## Data Sources

| Source | What to Find | How to Access |
|--------|--------------|---------------|
| **Speaker Form Results** | Previous submission (bio, photo, LinkedIn, abstract, theme) | `gsheets_read` spreadsheetId: `1GN2mAqlv_QRdCD4cuIplw_8IbwfjwpdlHTe7CSlcagY` |
| **Gmail** | Recent thread with speaker about upcoming event (topic direction, format, date) | `search_gmail_messages` with `q: "from:wmfrederick+producttanksf@gmail.com OR to:wmfrederick+producttanksf@gmail.com [speaker name]"` |
| **Master Event Spreadsheet** | Event date, venue, sponsor | `gsheets_read` spreadsheetId: `1RnNx_kF0YsaiG2VlcgMO1oVs56rjKBIxtQKjVsvwq2o` |

## Workflow

### Step 1: Pull the speaker's previous form submission

Read the Speaker Form Results spreadsheet. The columns are:

| Col | Field | Reusable? |
|-----|-------|-----------|
| A | Timestamp | No |
| B | Triaged | No |
| C | Qualified | No |
| D | Speaker Name | Yes |
| E | Why do you want to speak at ProductTank? | No |
| F | Theme | **New needed** (event-specific) |
| G | Abstract | **New needed** (event-specific) |
| H | 3-5 key learning outcomes | **New needed** (event-specific) |
| I | Target audience | Confirm |
| J | Product experience | Yes |
| K | PM approach | Yes |
| L | Speaking experience | Yes |
| M | Email | Yes |
| N | LinkedIn Profile URL | Yes |
| O | Bio | **Confirm** (may have changed roles) |
| P | Photo | **Confirm** (may want updated) |
| Q | Referral | Yes |
| R | Email Address | Yes |

Read the header row (A1:R1) and the speaker's row to get their data.

### Step 2: Pull the latest email thread

Search Gmail for the speaker's name to find the active thread about the upcoming event. Extract:
- Confirmed or tentative event date
- Venue/sponsor
- Topic direction the speaker has mentioned
- Format preference (presentation, fireside chat, workshop, etc.)
- Any content the speaker has already provided in email

### Step 3: Find a recent strong submission for format examples

Look for a recent, fully-populated form submission to use as a style model for the examples in the email. Read that row and extract their:
- Theme/title (column F)
- Abstract (column G)
- Key learning outcomes (column H)

### Step 4: Draft examples in that style, applied to the returning speaker's topic

Using the format model's style and the returning speaker's topic direction from the email thread:
- Draft a sample talk title
- Draft a sample abstract (2-3 sentences)
- Draft sample key takeaways (3-5 bullets starting with "Attendees will learn:")

These are suggestions to reduce friction, not prescriptions. Frame them as "e.g." examples.

### Step 5: Set the deadline

Determine the deadline based on the event calendar:
- Identify the event immediately before the speaker's event
- The meetUp page and promo slide launch the day before or the day of that preceding event
- Work backward: the speaker's info is needed before the weekend prior to that launch
- State the deadline as a specific date (day of week + month/day)

### Step 6: Compose the email using the template

Read `references/email-template.md` for the template. Fill in all {{variables}}.

## Output Rules

- The email is markdown but should be presented in **final display style** (rendered, not as raw markdown). Present it as a formatted block the user can review and copy.
- Do NOT use em-dashes anywhere in the email. Use commas, periods, or semicolons instead.
- Front-load the ask. The three items we need go at the top. Confirmation content goes below.
- Include the speaker's existing bio verbatim (1:1 from the spreadsheet) in a blockquote so they can scan and confirm.
- Include the headshot link if one exists in column P.
- Keep the tone conversational and warm. This is a returning speaker who already knows the community.
