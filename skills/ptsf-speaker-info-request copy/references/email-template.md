# Speaker Info Request Email Template

## Template

```
Subject: Re: {{email_thread_subject}}

Hi {{speaker_first_name}},

{{timeline_context}} We will launch the **promo for {{event_date}} @ {{venue_sponsor}}** {{promo_launch_timing}}. I will assemble the promo slides and MeetUp page this weekend.

I **need three things** from you by **{{deadline_day}}, {{deadline_date}}:**
1. **Talk title** (e.g., _"{{example_title}}"_)
2. **Abstract** (e.g., _"{{example_abstract}}"_)
3. **Key takeaways** (e.g., _"{{example_takeaways}}"_)

{{#if speaker_topic_quote}}
> {{speaker_topic_quote}}

{{/if}}
**Please also confirm the below is still current:**
_Bio:_
> {{speaker_bio}}

_Headshot:_
{{#if headshot_link}}
- [{{headshot_link}}]({{headshot_link}})
{{else}}
- (none on file, please send one)
{{/if}}

**Format confirmed** as {{confirmed_format}}.

Thank you, Wesley
```

## Variable Definitions

| Variable | Source | Description |
|----------|--------|-------------|
| `email_thread_subject` | Gmail thread | Subject line of the existing thread to keep it threaded |
| `speaker_first_name` | Speaker Form col D | First name only |
| `timeline_context` | Event calendar | Brief sentence about the preceding event creating urgency (e.g., "Our February event is next Wednesday.") |
| `event_date` | Gmail thread / Master spreadsheet | Target date(s) for the speaker's event (e.g., "March 25th (or 26th)") |
| `venue_sponsor` | Gmail thread / Master spreadsheet | Venue or sponsor name (e.g., "ProductBoard") |
| `promo_launch_timing` | Event calendar | When promo goes live relative to preceding event (e.g., "next Tuesday or on the day of the event") |
| `deadline_day` | Calculated | Day of week for the deadline |
| `deadline_date` | Calculated | Specific date (e.g., "February 20th") |
| `example_title` | Drafted from recent submission style + speaker's topic | A punchy talk title suggestion |
| `example_abstract` | Drafted from recent submission style + speaker's topic | 2-3 sentence abstract suggestion |
| `example_takeaways` | Drafted from recent submission style + speaker's topic | "Attendees will learn:" followed by 3-5 items |
| `speaker_topic_quote` | Gmail thread | The speaker's own words describing their topic direction, used verbatim in a blockquote. Include only if the speaker articulated a clear topic direction in email. |
| `speaker_bio` | Speaker Form col O | Verbatim bio from their previous submission |
| `headshot_link` | Speaker Form col P | Google Drive link to their photo, or empty |
| `confirmed_format` | Gmail thread | Format the speaker confirmed (e.g., "presentation with a lite audience participation segment") |

## One-Shot Example: Elena Luneva (March 2026)

**Context:** Elena spoke at the January 2025 event ("From Product to Leadership: CPO and General Manager"). She volunteered to return for March 2026. Her Speaker Form row (21) had her bio, photo, LinkedIn, and details from her January talk. The Gmail thread confirmed she wanted to speak about AI team readiness, with a presentation format. A recent strong submission (Anna Jacobi, row 33) provided the style model for examples.

**Filled template:**

---

Hi Elena,

Our February event is next Wednesday. We will launch the **promo for March 25th (or 26th) @ ProductBoard** next Tuesday or on the day of the event. I will assemble the promo slides and MeetUp page this weekend.

I **need three things** from you by **Friday, February 20th:**
1. **Talk title** (e.g., _"From Dabbling to Deploying: What It Takes to Lead AI-Ready Teams"_)
2. **Abstract** (e.g., _"Most product teams assume AI readiness is a tooling problem. In practice, the hardest failures happen earlier, when teams try to move from experimenting with AI to building and shipping non-deterministic systems at scale. This talk draws on original survey data and Elena's work co-teaching the Lead AI-First Teams Workshop to show what actually separates teams that ship from teams that stall."_)
3. **Key takeaways** (e.g., _"Attendees will learn: how to identify where teams break down when moving from AI dabbling to real deployment; what non-deterministic systems demand that traditional MVP thinking doesn't prepare you for; and repeatable patterns for building AI readiness across resourcing, governance, and change management."_)

**Please also confirm the below is still current:**
_Bio:_
> I am the Chief Product Officer and General Manager at Braintrust an AI recruiting solution and career platform. I lead the product, design, and AI teams building the future of work. I have delivered winning products, scaled global businesses, and built teams across Nextdoor, Nuna, LiquidSpace, Opentable, and BlackRock. I have a B.S. in Computer Science and Biology from NYU and an MBA from NYU and LBS.
>
> I advise companies on moving ideas through viable execution, innovation, building for customers, and attracting diverse teams. People seek to work with me again. I mentor and teach product, design, and data leaders. I love to build stuff with smart people.

_Headshot:_
- [https://drive.google.com/file/d/1ro7purMWRPUbGrZ8iqzackZ6hl3Mp8vU/view?usp=sharing](https://drive.google.com/file/d/1ro7purMWRPUbGrZ8iqzackZ6hl3Mp8vU/view?usp=sharing)

**Format confirmed** as presentation with a lite audience participation segment.

Thank you, Wesley

---

## Why This Format Works

The email structure follows three principles:

1. **Ask first, confirm second.** The speaker sees the three deliverables immediately. The bio confirmation is lower priority and can be handled with a quick "looks good" or a paste-over.

2. **Examples reduce friction.** Returning speakers have already been through the form once. Giving them drafted examples modeled on their own topic direction (not generic placeholders) means they can accept, edit, or rewrite rather than start from scratch.

3. **Deadline tied to a real event.** "Our February event is next Wednesday" creates natural urgency without being pushy. The speaker understands why the timeline matters.
