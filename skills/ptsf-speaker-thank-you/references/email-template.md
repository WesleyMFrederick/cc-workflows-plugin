# Speaker Thank You Email Template

## Template

```
Subject: Thank You for Speaking at ProductTank SF in {{year}}

Hi {{speaker_first_name}},

Thank you for speaking at our {{month}} event at {{venue}}. Your talk on {{theme_summary}} was fantastic. The audience was engaged throughout.

{{#if youtube_url}}
Here's the link to your talk on YouTube: [{{video_title}}]({{youtube_url}})
{{/if}}

The entire ProductTank community appreciates your willingness to contribute. We'd love to work with you again in the future, whether that's another talk, a panel, or just staying connected with the ProductTank SF community.

Thank you again from me and on behalf of Karsh, Melissa, Jerry, Betty, and Glenn.

Best,
Wesley
```

## Variable Definitions

| Variable | Source | Description |
|----------|--------|-------------|
| `year` | Spreadsheet col B | The year being thanked for (e.g., "2025") |
| `speaker_first_name` | Spreadsheet col AA | First name only |
| `month` | Derived from col A | Month name of the event (e.g., "August") |
| `venue` | Spreadsheet col Q | Venue company name |
| `theme_summary` | Derived from col D | 2-4 word lowercase summary of the talk theme |
| `video_title` | Spreadsheet col H | YouTube video title, only if populated |
| `youtube_url` | Spreadsheet col I | YouTube URL, only if a real URL exists (not placeholder text) |

## Conditional Logic

- If `youtube_url` is empty or placeholder text (not a real URL), omit the entire YouTube paragraph
- If `video_title` is empty but `youtube_url` exists, use a generic link text like "your talk"

## Example: Tom Alterman (August 2025)

**To:** thomas.alterman@gmail.com
**Subject:** Thank You for Speaking at ProductTank SF in 2025

Hi Tom,

Thank you for speaking at our August event at Neon. Your talk on building AI voice agents was fantastic. The audience was engaged throughout.

Here's the link to your talk on YouTube: [So you want to build an AI voice agent | Tom Alterman | ProductTank SF](https://www.youtube.com/watch?v=spjwvuSMVN0)

The entire ProductTank community appreciates your willingness to contribute. We'd love to work with you again in the future, whether that's another talk, a panel, or just staying connected with the ProductTank SF community.

Thank you again from me and on behalf of Karsh, Melissa, Jerry, Betty, and Glenn.

Best,
Wesley
