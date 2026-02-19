# Sponsor Thank You Email Template

## Grouping Logic

1. Filter to target year events only
2. Group all events by sponsor company
3. For each company, collect ALL event months and YouTube URLs
4. Deduplicate contacts: if Venue Sponsor Contact and Space Logistics Contact are the same person/email, send one email
5. If contacts are different people, CC the Space Logistics Contact
6. Create ONE email draft per company (not per event)

## Sponsor Classification

| Type | Logic |
|------|-------|
| **Venue-only** | In Column Q (Venue: Company), not in Column AI (F&B Sponsor Company) |
| **F&B-only** | In Column AI, not in Column Q |
| **Venue + F&B** | Same company in Q AND AI (or Column T) |
| **Mixed** | Different sponsorship types across events |
| **F&B + Videography** | F&B sponsor who also covered video production |

## Email Structure

```
**To:** {{venue_event_contact_email}}

**CC:** {{venue_space_contact_email}} (only if different person), jerryjyoung@gmail.com, karsh.pandey@gmail.com, emargulies@gmail.com, melissahsu2016@gmail.com

**Subject:** ProductTank SF Thanks You for an Amazing {{year}}{{" at " + company if venue sponsor}}
```

## Opening (by event count)

### 3+ events

Hi {{first_name(s)}},

What a year! {{company}} helped us out big time in {{year}}. {{contribution_description}}

### 2 events

Hi {{first_name(s)}},

Thank you for supporting ProductTank SF this year. {{contribution_description}}

### 1 event

Hi {{first_name(s)}},

Thank you for supporting our {{month}} ProductTank SF event. {{contribution_description}}

## Contribution Language

| Type | Language |
|------|----------|
| Venue only | "You hosted {{count}} events at {{company}}, giving our community a welcoming space to connect, learn, and grow together." |
| F&B only | "Your generous sponsorship of food and beverages for our {{months}} events kept our community energized and made networking that much easier." |
| Venue + F&B | "You hosted us {{count}} times at {{company}} and kept everyone fed. You sponsored the full package that makes our events special." |
| Mixed | "You sponsored food and beverages for our {{month}} event, then went above and beyond by hosting us at {{company}} for our {{month}} event." |
| F&B + Videography | "Your sponsorship of food and beverages, plus covering our video production, helped us create content our community can enjoy long after the event ended." |

## Video Section (include only if at least one YouTube URL exists)

```
I wanted to share the recording(s) from {{those evenings / that evening}} in case {{they are / it is}} useful for your own channels:

- {{month}}: [{{video_title}}]({{youtube_url}})
- {{month}}: We are still finalizing this one and will send the link once it is ready.
```

Adjust singular/plural: "evening/evenings", "recording/recordings", "it is/they are".

If a venue has NO YouTube URLs at all, omit the video section entirely.
If some events have URLs and some do not, list available URLs and note pending ones.

## Closing

```
We could not have pulled off {{year}} without you. We would love to continue working together in {{next_year}}.

Thank you again from me and on behalf of Karsh, Melissa, Jerry, Betty, and Glenn.

Best,
Wesley
```

## Special Cases

1. **Joint sponsorships** (e.g., "Arize, VAPI" in F&B column): Separate emails per company. Acknowledge collaboration with "alongside {{other_company}}".

2. **Multiple contacts same company**: All contacts in To field. Address all names in greeting (e.g., "Hi Teddy and Marco,").

3. **Individual sponsors** (no company): Do not reference company name. Address by name only.

4. **If CC-ing a second contact**: Address both names in greeting.

## Linear Tracking

### Description Table Format

```markdown
| Sponsor | Type | Events | Contact | Email | Status |
| -- | -- | -- | -- | -- | -- |
| Neon | Venue only | Jul, Aug | Teddy | teddy@neon.work | Sent |
| Cribl | Venue + F&B | Sep, Feb | Glen, Casey | gblock@cribl.io | Not sent |
| VAPI | Venue only | Oct | Dan | dan@vapi.ai | Blocked |
```

Status values: "Sent", "Not sent", "Blocked" (missing contact info)

### Comment Format for Sent Emails

```
## {{Sponsor}} - Sent {{date}}

**To:** {{recipients}}
**Subject:** {{subject}}

---

{{email body}}
```

## Formatting Rules

- No em dashes anywhere. Use commas, periods, or "and" instead.
- To, CC, Subject each on its own line with blank line between
- Keep grammar natural: adjust singular/plural throughout
