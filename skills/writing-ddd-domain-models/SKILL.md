---
name: writing-ddd-domain-models
description: Capture domain models from workflows you perform or observe. Produces data shapes (AND/OR), process trees (operator notation), and DDD workflow pseudocode. Use after completing a multi-step workflow to document what happened so a future session can reproduce it.
---

# Writing DDD Domain Models

## When to Use

- After completing a multi-step workflow (API calls, data transformations, file creation)
- When the user asks to "capture the domain model" or "trace what we just did"
- When documenting a repeatable process for future sessions
- When modeling a bounded context from observed behavior

## Baseline / Ideal / Delta

**Baseline** is the complete, current system state — entities, values, relationships, workflows, and metrics as they actually exist and operate today. Baseline answers: "how does the system work right now?" It must be measurable, documented, and timestamped.

**Ideal** is the target system configuration — not goals alone, but a fully described future state using the same structure and units as the baseline. If baseline and ideal aren't comparable like-to-like, the plan is invalid.

**Delta** is the set of state change operations that transform baseline into ideal. Delta is not "build feature X" — it is expressed as concrete modifications to entities, values, workflows, or architecture. Delta must be measurable in the same units as baseline and ideal.

The invariant: `Baseline State → Delta → Ideal State`. All three use identical schema.

## Two Modes

### Mode 1: Capture (trace what happened — baseline)
You just performed or observed a workflow. Now extract the domain model from it. This produces a **baseline**: what the system actually did, not what it could do.

### Mode 2: Write (author from requirements — ideal/delta)
You're writing data shapes, process trees, or workflows from scratch or from a spec. This may produce an **ideal** (target state) or **delta** (transformation plan).

Both modes use the same notation rules below.

---

## Part 1: Capture Protocol (Baseline)

When tracing a workflow you performed, capture these layers in order.

**Baseline Rule:** In capture mode, model only what DID happen. No speculative `×` branches for paths not taken. No `∧` parallel for steps that ran sequentially. Every operator must correspond to actual execution. Use comments with real data (actual IDs, actual row numbers, actual values). Speculative alternatives belong in ideal/delta artifacts.

### Step 1: Tool Call Inventory

List every tool call made during the workflow. Be concrete and specific.

```markdown
## Tool Calls

| # | Process Tree Step | Workflow Substep | Tool | Call | Purpose |
|---|-------------------|------------------|------|------|---------|
| 1 | IdentifyChannel | do IdentifyChannel | Slack MCP | `channels_list(channel_types, limit)` | Find channel by name |
| 2 | FetchChannelMembers | do FetchChannelMembers | Bash/curl | `curl -s "https://slack.com/api/conversations.members?channel={id}"` | Get member IDs (no MCP tool) |
| 3 | ResolveUserProfiles | do ResolveUserProfiles (for each) | Bash/curl | `curl -s "https://slack.com/api/users.info?user={id}"` x12 | Resolve user profiles + email |
| 4 | FetchConversationHistory | do FetchConversationHistory | Slack MCP | `conversations_history(channel_id, limit)` | Fetch all messages |
| 5 | FetchThreadReplies | do FetchThreadReplies (for each) | Slack MCP | `conversations_replies(channel_id, thread_ts)` x6 | Fetch thread replies |
| 6 | Propagate → WriteCell | do WriteSpreadsheetCells | GDrive MCP | `gsheets_update_cell(fileId, range, value)` | Write to spreadsheet |
```

Each row connects a concrete tool call to its process tree step and workflow substep. This single table replaces separate tool inventory and tool-to-workflow mapping tables.

Distinguish between:
- **MCP tools** — name the exact tool and parameters
- **REST API calls** — name the endpoint, method, key params
- **Bash commands** — the actual command run
- **File operations** — Read/Write/Edit with paths

### Step 2: Data Shapes

Extract entities from the data you touched. Use AND/OR notation.

### Step 3: Process Trees

Model the execution flow using operator notation.

### Step 4: Workflows

Write the DDD pseudocode version.

### Step 5: Observations

Note any environmental dependencies (token scopes, tool availability, fallback paths).

---

## Part 2: Notation Rules

### Data Shapes (AND/OR)

```
data Order =
    CustomerInfo
    AND ShippingAddress
    AND BillingAddress
    AND list of OrderLine
    AND AmountToBill

data ProductCode = WidgetCode OR GizmoCode
```

Rules:
- `AND` = all fields present (product type)
- `OR` = one of these alternatives (sum type)
- `list of X` = zero or more of X
- Keep shapes flat unless nesting adds clarity
- Value objects get their own `data` block when reused

### Process Trees

**Operators**: `→` sequential, `×` exclusive choice, `∧` parallel, `↻` redo loop

**Silent activity**: `τ` (tau) — an unobservable activity used to model optional steps, unconditional loops, and structural routing.

#### Formal Definition

A process tree is built from activities (leaf nodes) and operators (inner nodes):
- A single activity `a` (or `τ`) is a process tree
- `→(Q1, Q2, ..., Qn)`, `×(Q1, Q2, ..., Qn)`, `∧(Q1, Q2, ..., Qn)` where n ≥ 1 are process trees
- `↻(Q1, Q2, ..., Qn)` where n ≥ 2 is a process tree (at least one "do" and one "redo" child)

#### Redo Loop Semantics

The `↻` operator has a **"do" part** (first child) and one or more **"redo" parts** (remaining children). Execution always starts and ends with the "do" part. When looping back, one "redo" part executes before returning to "do".

- `↻(a, b)` — execute `a`, then optionally loop: execute `b` then `a` again. Traces: `a`, `a,b,a`, `a,b,a,b,a`, ...
- `↻(a, b, c)` — execute `a`, then optionally loop via `b` OR `c`. Traces: `a`, `a,b,a`, `a,c,a`, `a,b,a,c,a`, ...

#### Silent Activity Patterns

- `×(a, τ)` — activity `a` that can be skipped (optional)
- `↻(a, τ)` — execute `a` one or more times. The "redo" part is silent, so the loop repeats without visible activity
- `↻(τ, a)` — execute `a` zero or more times. The "do" part is silent, so the process can skip `a` entirely
- `↻(τ, a, b, c, ..., z)` — any sequence of activities from the set. Equivalent to Kleene star over the alphabet

#### Formatting Rules

1. **`Name =` is optional** — Use when the trace is referenced elsewhere or is a named sub-process. If used, the `=` is required.

2. **Operators at same column as alias** — Top-level operators align at the same indent level as the `Name =` declaration. This makes the main flow scannable as a single vertical column.

3. **Sub-processes indent further** — Named sub-processes inside groups indent deeper and use `Name =` for readability at depth.

4. **`↻` is a redo loop, NOT a for-each** — `↻(do-part, redo-part, ...)` models non-deterministic repetition where the process MAY loop back (see Redo Loop Semantics above). Data-driven iteration ("for each item in collection") belongs in **workflow pseudocode only**, not in process trees. Process trees model control flow patterns, not data-driven iteration.

5. **Closing `)` aligns with opening operator** — The `)` sits at the same column as the `∧`, `×`, or `↻` that opened the `(`. 

6. **Grouping `()` with commas** — Multi-branch operators use parenthesized, comma-separated branches.

7. **Comments with `//`** — Inside the code block for clarifying non-obvious behavior or design rationale.

8. **Comment indentation** — Comments indent one tab deeper than their parent operator:
    ```
    → step
    		// comment about step (one extra tab from →)
    → next step
    ```

9. **Leaf actions are plain text** — No operator prefix for terminal actions.

#### Examples

**Sequential with parallel fork-join:**
```
ExportSlackChannel =
→ IdentifyChannel
∧ (
		 FetchChannelMembers → ResolveUserProfiles,
		 FetchConversationHistory → FetchThreadReplies
	)
→ ∧ (SynthesizeDRIAssignments, ExtractKeyDecisions, ExtractOpenItems, BuildUserLookupTable)
→ AssembleExportDocument
→ WriteFile
```

**Exclusive choice:**
```
IdentifyChannel =
× (
		ChannelIdProvided → use directly,
		ChannelNameProvided → SearchChannelsList → match by name → extract ChannelId,
		DescriptionProvided → SearchChannelsList → fuzzy match → extract ChannelId
	)
```

**Redo loop with nested parallel and sub-processes:**
```
ResolveOneUserProfile =
→ CallSlackAPI("users.info", UserId)
→ extract RealName, UserName, Email
∧ (
		InferRoleFromContext =
		× (
				MessageContentIndicatesRole → assign specific role,
				EmailDomainMatchesVenueCompany → assign venue-related role,
				MentionedInDRIContext → assign from DRI,
				NoSignals → assign Member
		),
		InferOrgFromEmail =
		× (
				EmailDomain matches known company → assign CompanyName,
				EmailDomain is personal (gmail, etc.) → assign "ProductTank SF",
				NoEmail → assign Unknown
		)
	)
→ yield ChannelMember

ResolveAllUserProfiles =
↻ (ResolveOneUserProfile, τ)
	// do: resolve one profile
	// redo: silent (loop back unconditionally while members remain)
	// NOTE: data-driven iteration (for each member) is modeled
	//   in workflow pseudocode; process tree captures the control flow pattern
```

**Redo loop (do/redo pattern):**
```
RetryWithBackoff =
↻ (
		→ (SendRequest, CheckResponse),
		→ (WaitBackoff, LogRetry)
	)
	// do: send request and check response
	// redo: wait, log, then loop back to do
	// traces: (send,check), (send,check,wait,log,send,check), ...
```

**Silent activity — optional step:**
```
MaybeNotifyUser =
× (SendNotification, τ)
	// either send notification, or skip silently
```

**Silent activity — zero-or-more repetition:**
```
ProcessAnyMessages =
↻ (τ, HandleMessage)
	// do part is silent: can skip entirely
	// redo part handles one message per loop
	// traces: ε, (handle), (handle,handle), (handle,handle,handle), ...
```

**Silent activity — one-or-more repetition:**
```
ProcessAtLeastOneMessage =
↻ (HandleMessage, τ)
	// do part executes at least once
	// redo part is silent: loop back without visible activity
	// traces: (handle), (handle,handle), (handle,handle,handle), ...
```

### Workflows (DDD Pseudocode)

```
bounded context: Context Name

workflow "Workflow Name"
    triggered by:
        "Event or command name" (context)
    primary input:
        InputType
    other input:
        Additional dependencies
    output events:
        "Event Name" event (key fields)
    side-effects:
        Description of external effects

    // substeps
    do StepOne
    if condition then:
        stop with error

    concurrently:
        do BranchA
            then do DependentOnA
        do BranchB
            then do DependentOnB
    await all

    concurrently:
        do ParallelStepX
        do ParallelStepY
    await all

    do FinalStep

    return "Output Event" event
```

#### Workflow Rules

1. **No process tree operators** — Workflows use `concurrently:` / `await all` for parallelism, not `∧`.
2. **`await all` always** — Never `await both` even for exactly 2 branches. Consistent keyword.
3. **`then do`** — Marks a dependency within a concurrent block (B depends on A completing).
4. **Substeps use same structure** — Each substep can have its own `input:` / `output:` / `side-effects:` block.
5. **Prose-readable** — Workflows read as business logic, not formal notation. Process trees handle the formal semantics.

### Observations Section

Use data shapes for type definitions, plain prose for behavioral notes. No process tree operators in observations.

```
## Observations

### Topic Name

data TypeName = OptionA OR OptionB

- Prose explanation of when each option applies
- Environmental dependencies or constraints
```

### Programmatic Naming

Derive function names from process tree structure using a 3-component grammar:

```
FunctionName = {verb} + {domainEntity} + {discriminant}
```

**Verb** — from operator type:

| Operator | Verb | Example |
|----------|------|---------|
| `×` node (dispatcher) | `identify` | `identifySlackChannel` |
| `×` branch | `resolve` | `resolveSlackChannelById` |
| `→` chain (pipeline) | `export`, `process` | `exportSlackThread` |
| `∧` group (parallel) | `fetch`, `gather` | `fetchAllProfiles` |
| `↻` (repetition) | base verb, plural entity | `resolveSlackUsers` |
| Leaf (synthesis) | `infer`, `build` | `inferOrgFromEmail` |
| Leaf (API/write) | `fetch`, `propagate` | `propagateSpreadsheetCells` |

**Domain entity** — from output data shape. Strip state-adjective prefixes (`Resolved`, `Enriched`) to get the domain noun. Pluralize for `↻` nodes (collection I/O).

**Discriminant** — only for `×` children. Convert branch label to `By` + noun: `ChannelIdProvided` → `ById`.

See `references/programmatic-naming.md` for full grammar, derivation rules, and applied examples.

---

## Output Structure

The final document follows this structure:

```markdown
# {Domain Name} — Data Shapes & Workflows

## Tool Calls
(merged table: #, Process Tree Step, Workflow Substep, Tool, Call, Purpose)

## Data Shapes
### Core Entities
### Derived / Synthesized Entities
### Aggregate Root
### Value Objects

## Process Trees
- Use process tree operators: → sequential, × exclusive choice, ∧ parallel, ↻ redo loop

### Trace 1: ...
### Trace 2: ...

## Workflows
### Primary Workflow: ...
### Substep: ...

## Observations
```

---

## Anti-Patterns

- **Mixing notations**: Don't use `∧` in workflows or `concurrently:` in process trees
- **Flat parallel that hides dependencies**: `∧ A, B → C` is ambiguous. Use `∧ (A, B → C)` to show C depends on B, or `∧ (A → C, B)` if C depends on A
- **`for each` in process trees**: Wrong. Process trees model control flow patterns, not data-driven iteration. Use `↻(action, τ)` to model the repetition pattern; put the `for each` logic in workflow pseudocode
- **Separate trace for inlined sub-process**: If a sub-process is only used in one place, inline it with `Name =` inside the parent trace. Don't create a separate trace.
- **`await both`**: Always `await all` for consistency
- **Process tree operators in Observations**: Use data shapes + prose instead
- **Verification/smoke-test tools in baseline tool table**: Tool calls that verify infrastructure (e.g. "test if MCP works") are not part of the domain workflow. Exclude them from the Tool Calls table.
- **Speculative parallelism in baseline**: Don't mark steps as `∧` parallel because they COULD run in parallel. In baseline captures, only use `∧` when steps actually executed concurrently. Sequential execution = `→`.
- **Missing τ for optional/skippable steps**: If a step can be skipped entirely, model it as `×(step, τ)`, not as an unlabeled gap. Silent transitions make optionality explicit.
- **Redo loop with only one child**: `↻` requires at least 2 children (one "do", one or more "redo"). A single-child loop is invalid — use `↻(do-part, τ)` for unconditional looping.
- **`Each` suffix on `↻` functions**: Wrong. `↻` is a redo loop, not for-each. Use plural entity name (`resolveSlackUsers`) not `resolveEachSlackUser`. Data-driven iteration belongs in workflow pseudocode.
