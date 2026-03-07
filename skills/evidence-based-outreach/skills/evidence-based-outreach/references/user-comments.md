# Parsing User Comments in Draft Files

Users review draft markdown files and leave inline feedback using Obsidian's commenting/highlighting features or manual annotations. Recognize and act on all of these patterns.

## Comment Formats to Recognize

### Obsidian Highlights (most common)
```markdown
<mark class="user-highlight" data-user-name="Wesley" data-created="...">comment text here</mark>
```
These appear inline, adjacent to the text they modify. The comment text IS the instruction.

### Strikethroughs (deletions)
```markdown
~~word or phrase to remove~~
```
When a strikethrough appears next to a highlight, the user wants to replace the struck text with what the highlight says.

### Combined pattern (replace)
```markdown
~~old text~~<mark class="user-highlight">new text or instruction</mark>
```
This means: replace "old text" with "new text" or follow the instruction.

### Inline instructions
Comments that give directives rather than replacement text:
```markdown
<mark class="user-highlight">insert device name</mark>
<mark class="user-highlight">do additional research to bump this claim up</mark>
<mark class="user-highlight">my expressed desire</mark>
```

### Score corrections
Users may strike through dB scores and replace them:
```markdown
~~**5**~~<mark class="user-highlight">3</mark>
```
This means: change the claim's dB score to the new value. Update the Evidence Type column to match.

### Rationale comments
Sometimes the user explains WHY a score should change:
```markdown
<mark class="user-highlight">Should be similar db as 4 since I could have gotten the conversation wrong</mark>
```
Use this rationale in the updated "Changes from vN" section.

## Processing Rules

1. **Read the entire file** looking for `<mark>` tags and `~~` strikethroughs
2. **Categorize each comment:**
   - Text replacement (strikethrough + highlight)
   - Insertion (highlight alone adjacent to text)
   - Score adjustment (strikethrough on a dB number + new number)
   - Research request ("do additional research", "bump this claim up")
   - Rationale (explains reasoning, use in changelog)
3. **Apply all changes** to produce the next version
4. **For research requests:** spawn a Task subagent to find corroboration, then update the claim score with the new evidence
5. **Update the changelog** section ("Changes from vN") listing every change and why
6. **Preserve all evidence traces** — update links if claims change, add new traces for research-strengthened claims

## Version Bumping

When incorporating comments:
- Bump the version header: "Reply Draft v1" → "Reply Draft v2"
- Add a "Changes from vN" section listing all modifications
- Include rationale from user comments where provided
- Note any dB score changes with before/after and why
