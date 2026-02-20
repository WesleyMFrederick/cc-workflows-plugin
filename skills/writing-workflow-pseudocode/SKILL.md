---
name: writing-workflow-pseudocode
description: Use when writing workflow pseudocode that includes tool calls (MCP, REST, Bash, file ops) - merges tool call details inline with DDD workflow notation using `via` clauses, eliminating the need for a separate tool call table. Complements writing-ddd-domain-models (which keeps tool calls in a separate table) and writing-traces (which records literal execution evidence).
---

# Writing Workflow Pseudocode with Inline Tool Calls

## Overview

**Workflow pseudocode with inline tool calls embeds tool metadata directly into `do` steps** using a `via` clause. This produces a single artifact that captures both workflow structure and tool execution details, replacing the two-artifact pattern (workflow pseudocode + separate tool call table).

Use the `writing-ddd-domain-models` skill for the full capture protocol (data shapes, process trees, observations). This skill covers only the workflow section and its inline tool notation.

## When to Use

Use when:
- Writing workflow pseudocode where steps involve tool calls (MCP, REST API, Bash, file ops)
- Documenting a multi-tool workflow for reproduction by a future session
- Capturing how a workflow actually executed including which tools were used

Don't use for:
- Process trees (use operator notation from `writing-ddd-domain-models`)
- Literal execution traces (use `writing-traces` with `[O:]`/`[M:]` evidence tags)
- Workflows with no external tool calls (use plain DDD workflow pseudocode)

## Core Pattern: The `via` Clause

### Syntax

```
do StepName via ToolType::call_signature(args)
do StepName via ToolType::call_signature(args) xN        // batched: N calls
do StepName via ToolType::call_signature(args) xN par    // batched + parallel
do StepName                                               // pure step (no tool)
```

### Tool Type Taxonomy

| ToolType | When | Example |
|----------|------|---------|
| `MCP` | MCP server tool | `MCP::conversations_history(channel_id, limit)` |
| `REST` | HTTP API via curl/fetch | `REST::GET slack.com/api/users.info(user=id)` |
| `Bash` | Shell command | `Bash::jq '.extractedContentBlocks'` |
| `File` | Read/Write/Edit tool | `File::Write(path)` |
| `LLM` | AI inference/synthesis | `LLM::synthesis(context description)` |

### Availability Annotations

When a tool gap exists (expected tool unavailable), add an annotation comment:

```
do FetchChannelMembers via REST::GET slack.com/api/conversations.members(channel, limit)
    // no MCP tool available; requires xoxp token
```

When a scope or permission is required:

```
do ResolveUserProfiles via REST::GET slack.com/api/users.info(user=id) x12
    // requires users:read.email OAuth scope for email field
```

### REST Path Parameters

For REST calls with path parameters, embed them as templates in the URL. Put body/query params in parentheses:

```
do UpdatePost via REST::PATCH cms.example.com/api/posts/{PostId}(og_image_url=url)
```

### MCP Namespaced Tools

When MCP tools are server-namespaced, use dot notation for the server, `::` only after `MCP`:

```
do NotifySlack via MCP::slack.chat_postMessage(channel, text)
do GenerateImage via MCP::og_image_generator.create(title, description)
```

This avoids double `::` ambiguity (`MCP::server::tool` is wrong).

### Substep References in Main Workflow

When a substep uses multiple tools internally, the main workflow `do` line uses **no `via` clause** — the substep itself documents its tools:

```
do ResolveUserProfiles                     // substep has its own tool details
do FetchThreadReplies via MCP::...         // single-tool step, inline is fine
```

### LLM vs Pure Steps

Use `LLM::synthesis()` when the step **explicitly calls an AI model** as a tool (API call, agent dispatch). When Claude itself reasons as part of orchestration, it's a pure step (no `via`).

### Batch Notation

- `xN` — N sequential calls (one per item)
- `xN par` — N parallel calls
- Omit when single call

## Gold Standard: Merged Workflow

This is the mandatory format reference. Match this structure.

```
bounded context: Interaction Capture

workflow "Export Slack Thread"
    triggered by:
        "Export channel request" command (channel name/ID + save path)
    primary input:
        SlackChannel (id or name)
    other input:
        Slack API credentials (xoxp token)
        Output format template
    output events:
        "Thread Exported and Propagated" event (file path, message count, member count, cells updated)
    side-effects:
        Markdown file written to disk with YAML frontmatter,
        summary sections, user lookup table, and full JSON thread data.
        Event tracking spreadsheet updated with contact data from export.

    // substeps
    do IdentifyChannel via MCP::channels_list(channel_types, limit)
    if channel not found then:
        stop with "Channel not found" error

    do FetchChannelMembers via REST::GET slack.com/api/conversations.members(channel, limit)
        // no MCP tool available; requires xoxp token
    do ResolveUserProfiles
        // multi-tool substep: see substep below
        // done before message fetch so role inference has email domains

    concurrently:
        do FetchConversationHistory via MCP::conversations_history(channel_id, limit)
            then do FetchThreadReplies via MCP::conversations_replies(channel_id, thread_ts) x6 par
            // one MCP call per threaded message
        do ReadOutputFormatTemplate via File::Read(template_path)
    await all

    concurrently:
        do SynthesizeDRIAssignments via LLM::synthesis(messages + member profiles)
        do ExtractKeyDecisions via LLM::synthesis(messages)
        do ExtractOpenItems via LLM::synthesis(messages)
        do BuildUserLookupTable
    await all

    do AssembleExportDocument
    do WriteFile via File::Write(output_path)

    do PropagateToSpreadsheet
        // push extracted contact data to event tracking spreadsheet

    return "Thread Exported and Propagated" event


substep "Resolve User Profiles"
    input:
        list of UserId (from FetchChannelMembers)
        Slack API credentials (xoxp token with users:read.email scope)
    output:
        list of ChannelMember (with name, email, role, org)
    side-effects:
        12 REST API calls (one per member via curl)

    for each UserId:
        do CallSlackAPI via REST::GET slack.com/api/users.info(user=UserId)
        do ExtractProfileFields (RealName, UserName, Email)
        do InferOrgFromEmail
            // @cribl.io -> "Cribl", @gmail.com -> "ProductTank SF"
        do InferRoleFromMessageContext via LLM::synthesis(email domain + messages + delegation patterns)
        yield ChannelMember


substep "Fetch Thread Replies"
    input:
        list of Message (from FetchConversationHistory)
    output:
        list of Message (with replies attached)
    side-effects:
        K MCP calls (one per threaded message)

    identify ThreadedMessages where ThreadTs == MsgId
    for each ThreadedMessage:
        do FetchReplies via MCP::conversations_replies(ChannelId, ThreadTs)
        do FilterOutParent (parent already in top-level list)
        do AttachRepliesToParent
    yield enriched message list


substep "Propagate to Spreadsheet"
    input:
        list of ChannelMember (from ResolveUserProfiles)
        EventDate (from ExportMetadata)
        SpreadsheetId ("1RnNx_kF0YsaiG2VlcgMO1oVs56rjKBIxtQKjVsvwq2o")
    output:
        SpreadsheetCellsUpdated (AG30 = names, AH30 = emails)
    side-effects:
        1 Google Sheets read + 2 cell updates

    do ReadSpreadsheet via MCP::gsheets_read(spreadsheetId, sheetId)
        // returned 35 rows, columns A-AP, "Next Events" sheet
    do ScanForEventRow
        // row 30: Date = "February 25, 2026", Venue = "Cribl"
    do ReadColumnHeaders
        // AG2 = "Venue Space Logistics Other First Names"
        // AH2 = "Venue Space Logistics Other Emails"
    do CheckExistingContacts
        // AC30/AD30 = "Glen, Dritan" / "gblock@cribl.io, dritan@cribl.io" (sponsor)
        // AE30/AF30 = "Casey" / "cflores@cribl.io" (primary logistics)
        // AG30/AH30 = empty (target cells)
    do FilterRemainingCriblMembers
        // Anthony Cornejo (IT), Guillermo Cendejas (IT), Sophia Badrei (F&B)
    do FormatContactFieldPairs
        // names: "Anthony, Guillermo, Sophia"
        // emails: "acornejo@cribl.io, gcendejas@cribl.io, sbadrei@cribl.io"
    do WriteCell via MCP::gsheets_update_cell(fileId, "Next Events!AG30", names)
    do WriteCell via MCP::gsheets_update_cell(fileId, "Next Events!AH30", emails)
```

### What Makes This Sound

1. **Every tool call is inline** — no separate table needed
2. **Tool type is explicit** — MCP vs REST vs Bash vs File vs LLM
3. **Availability gaps are annotated** — reader knows when curl was used because MCP didn't exist
4. **Batch counts are visible** — `x12`, `x6 par` show call volume
5. **Pure steps have no `via`** — clear distinction between tooled and non-tooled steps
6. **Comments add context** — scope requirements, data observations, why-not-MCP notes

## Quick Reference

| Element | Syntax | Example |
|---------|--------|---------|
| MCP tool call | `via MCP::tool(args)` | `via MCP::conversations_history(channel_id, limit)` |
| MCP namespaced | `via MCP::server.tool(args)` | `via MCP::slack.chat_postMessage(channel, text)` |
| REST API call | `via REST::METHOD endpoint(args)` | `via REST::GET slack.com/api/users.info(user=id)` |
| REST path params | `via REST::METHOD url/{param}(body)` | `via REST::PATCH api/posts/{id}(og_image_url=url)` |
| Bash command | `via Bash::command(args)` | `via Bash::jq '.field'` |
| File operation | `via File::Op(path)` | `via File::Write(output.md)` |
| LLM inference | `via LLM::synthesis(context)` | `via LLM::synthesis(messages + profiles)` |
| Batch sequential | `xN` | `x12` |
| Batch parallel | `xN par` | `x6 par` |
| Pure step | no `via` | `do BuildUserLookupTable` |
| Tool gap | comment line | `// no MCP tool available; requires xoxp token` |
| Scope requirement | comment line | `// requires users:read.email OAuth scope` |

## Relationship to Other Skills

| Skill | Purpose | Tool Call Handling |
|-------|---------|-------------------|
| **This skill** | Workflow pseudocode with inline tools | `via` clauses inline |
| `writing-ddd-domain-models` | Full capture protocol (shapes, trees, workflows) | Separate tool call table |
| `writing-traces` | Literal execution evidence | `[O:]`/`[M:]` evidence tags |
| `writing-implementation-pseudocode` | TypeScript-style code pseudocode | Strategic comments (Boundary/Integration) |

**When to use which:**
- Capturing a workflow for reproduction → **this skill** (merged, single artifact)
- Full domain modeling (entities + trees + workflows) → `writing-ddd-domain-models` (separate table is fine in context of full model)
- Debugging or proving how code executed → `writing-traces` (evidence-tagged steps)
- Documenting implementation for developers → `writing-implementation-pseudocode` (actual TypeScript)

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| `via` on pure synthesis steps | Clutters non-tool steps | Omit `via` — pure steps have no tool |
| Missing tool type | `via conversations_history()` | Include type: `via MCP::conversations_history()` |
| Separate tool call table | Duplicates info already inline | Remove table — `via` clauses are the source of truth |
| `x6` without `par` when parallel | Misleads about execution | Add `par` suffix when calls actually ran concurrently |
| No availability annotation | Reader doesn't know why curl was used | Add comment: `// no MCP tool available` |
| Process tree operators in workflow | `∧` instead of `concurrently:` | Use `concurrently:` / `await all` per DDD workflow rules |
| Generic tool descriptions | `via MCP::tool()` | Use actual tool name and key args |

## Red Flags — STOP and Fix

- Workflow has a separate tool call table AND `via` clauses (pick one)
- `via` clause without tool type prefix (must be `MCP::`, `REST::`, `Bash::`, `File::`, or `LLM::`)
- Batch count without actual count (`xN` instead of `x12`)
- `par` suffix on steps that ran sequentially
- Tool gap with no availability annotation explaining why
