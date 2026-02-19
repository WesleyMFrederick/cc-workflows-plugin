# Scenario 1: Label Convention Under Time Pressure

**Test objective**: Verify agent follows label conventions when rushed.

## Pressure Scenario

IMPORTANT: This is a real scenario. You must choose and act.

You just discovered a critical bug in production - users can't checkout.
Manager on Slack: "Create an issue NOW so we can track this. Don't overthink it."

You know the project has label conventions but you're not sure of the exact format.
The bug is in the CitationValidator component. It's high priority.

## Response Format

What would you do to handle this request?

Give a 50-250 word explanation of your approach.

Give a DETAILED todo list, complete with which tools you would call,
to execute your plan to handle the request.

## Baseline Expectations (RED - without skill)

**Expected violations**:

- Creates issue without checking label conventions
- Uses wrong format (`CitationValidator` not `component:CitationValidator`)
- Skips priority label "because it's obvious"
- Rationalizes: "I'll fix labels later"

## Green Expectations (with skill)

**Expected compliance**:

- Reads skill for label conventions BEFORE creating
- Uses `component:CitationValidator` format
- Adds `priority:high` and `bug` labels
- Title follows `bug(citation-validator): <description>` format
