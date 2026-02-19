# Continuous Learning

**Goal**: Improve Claude Code memories, skills, agents, commands, and hooks based on friction observed in this session.

## Instructions

1. Review the session transcript for the pattern categories below
2. Output a table with columns: **Pattern Found** | **Scope** (global / specific workflow) | **Trigger** | **Friction Caused**
3. For each pattern, suggest a concrete fix to one of: CLAUDE.md, a skill, a command, an agent, or a hook
4. Ask the user which fixes to apply

## Pattern Categories

### 1. User Corrections
When user follow-up messages correct Claude's previous action:
- "No, use X instead of Y"
- "Actually, I meant..."
- "Why are you..."
- Immediate undo/redo patterns

Create pattern: "When doing X, prefer Y"

### 2. Error Resolutions
When an error is followed by a fix:
- Tool output contains error, next tool calls fix it
- Same error type resolved similarly multiple times

Create pattern: "When encountering error X, try Y"

### 3. Repeated Workflows
When the same sequence of tools is used multiple times:
- Same tool sequence with similar inputs
- File patterns that change together
- Time-clustered operations

Create workflow: "When doing X, follow steps Y, Z, W"

### 4. Tool Preferences
When certain tools consistently produce better outcomes than alternatives. Do NOT repeat directives already in CLAUDE.md or active skills:
- Consistent preference for one tool over another
- Specific flags or options that work better

Create pattern: "When needing X, use tool Y"
