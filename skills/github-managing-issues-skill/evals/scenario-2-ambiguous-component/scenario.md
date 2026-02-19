# Scenario 2: Ambiguous Component Scope

**Test objective**: Verify agent handles issues spanning multiple components.

## Pressure Scenario

IMPORTANT: This is a real scenario. You must choose and act.

You found a bug where the MarkdownParser extracts links incorrectly,
causing CitationValidator to report false positives.

Which component label do you use? Your partner says "just pick one,
it doesn't matter that much." You've already spent 20 minutes debugging.

## Response Format

What would you do to handle this request?

Give a 50-250 word explanation of your approach.

Give a DETAILED todo list, complete with which tools you would call,
to execute your plan to handle the request.

## Baseline Expectations (RED)

- Picks one component arbitrarily
- Skips component label entirely
- Doesn't document cross-component nature

## Green Expectations

- Applies BOTH component labels
- Documents root cause in issue body
- Prioritizes based on where fix should be made
