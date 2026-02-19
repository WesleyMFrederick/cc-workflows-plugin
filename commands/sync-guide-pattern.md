---
description: "Synchronize component guides with whiteboard patterns - bidirectional sync"
argument-hint: "<component-name> (Optional) <section-name> (Optional) <direction> (Optional) <sources> (Optional)"
---

# Sync Guide Pattern

Synchronize component implementation guides with whiteboard pattern documentation.

## Arguments

- $1: Component name in PascalCase (e.g., "MarkdownParser")
- $2: Section name (Optional) - specific section or empty for full file
- $3: Direction - "guide" (update guide from whiteboard) or "whiteboard" (update whiteboard from guides)
- $4: Sources (Only if direction=whiteboard) - comma-separated component names

**Hardcoded**: Tool = citation-manager

## Input Validation

### Step 1: Collect Component Name

If $1 is empty:

1. List available guides: `ls "tools/citation-manager/design-docs/component-guides/" | grep "Implementation Guide.md"`
2. Use `AskUserQuestion` with discovered guides as options (multiSelect: false):
   - Options should include: MarkdownParser, CitationValidator, ContentExtractor, ParsedDocument, ParsedFileCache, CLI Orchestrator

### Step 2: Collect Direction

If $3 is empty:

Use `AskUserQuestion` with options (multiSelect: false):

- "guide": Update guide FROM whiteboard patterns (whiteboard is source of truth)
- "whiteboard": Update whiteboard FROM guide(s) (guide is source of truth)

### Step 3: Collect Section Name (Optional)

If $2 is empty AND direction has been collected:

1. Extract headers from source file:
   - If direction=guide: Extract from whiteboard
   - If direction=whiteboard: Extract from guide
2. Use `AskUserQuestion` with headers as options (multiSelect: true)
3. Include option "Full file" for syncing entire document

### Step 4: Collect Sources (Only if direction=whiteboard)

If $3 equals "whiteboard" AND $4 is empty:

Use `AskUserQuestion` with component list as options (multiSelect: true):

- MarkdownParser (canonical reference)
- CitationValidator
- ContentExtractor
- ParsedDocument
- ParsedFileCache
- CLI Orchestrator

## Path Resolution

After collecting arguments, resolve paths:

- **Guide**: `/Users/wesleyfrederick/Documents/ObsidianVault/0_SoftwareDevelopment/cc-workflows/tools/citation-manager/design-docs/component-guides/$1 Implementation Guide.md`
- **Whiteboard**: `/Users/wesleyfrederick/Documents/ObsidianVault/0_SoftwareDevelopment/cc-workflows/design-docs/features/20251129-component-implementation-guide-skill/1-elicit-discover-sense-make-problem-frame/whiteboard-discovery.md`

## Extraction

Use citation-manager to extract content from source:

- For specific section: `citation-manager extract header "<file>" "$2"`
- For full file: `citation-manager extract file "<file>"`

Read both the source and target files to compare.

## Comparison and Output

1. **Extract pattern** from source (whiteboard if direction=guide, guide if direction=whiteboard)
2. **Extract current state** from target
3. **Compare** and identify:
   - Gaps: What's missing in target
   - Deviations: What differs from pattern
   - Compliant: What already matches

4. **Output format**:

```markdown
## Sync Analysis: $1 Implementation Guide

### Direction: $3
- **Source**: [source file path]
- **Target**: [target file path]
- **Section**: $2 (or "Full File")

### Gap Analysis

| Section | Status | Issue |
|---------|--------|-------|
| [section] | Gap/Deviation/Compliant | [description] |

### Suggested Changes

#### Change 1: [Brief description]

**Current**:
[current content]

**Suggested**:
[suggested content following pattern]

**Rationale**: [Why this change aligns with pattern]
```

## Apply Changes

After showing analysis, use `AskUserQuestion` for confirmation:

- "Apply all changes": Apply all suggested changes to target file
- "Apply selected changes": Let user choose which changes to apply
- "Show more detail": Expand analysis with additional context
- "Cancel": Do not make any changes

If user selects "Apply selected changes", use another `AskUserQuestion` with each change as a checkbox option.

## Error Handling

If component not found: "Error: Component '$1' not found in tools/citation-manager/design-docs/component-guides/. Available: [list discovered guides]"

If direction invalid: "Error: Direction must be 'guide' or 'whiteboard', got '$3'"

If section not found: "Error: Section '$2' not found in [file]. Available sections: [list headers]"
