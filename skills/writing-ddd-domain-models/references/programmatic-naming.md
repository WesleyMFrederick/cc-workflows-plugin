# Programmatic Naming from Process Trees

Derive function names mechanically from process tree structure. Every name follows a 3-component grammar read directly from the tree.

## Naming Grammar

```
FunctionName = {verb} + {domainEntity} + {discriminant}
```

| Component | Source | Example |
|-----------|--------|---------|
| `verb` | Operator type (see table below) | `identify`, `resolve`, `fetch` |
| `domainEntity` | Output data shape (strip adjective prefix, pluralize for collections) | `SlackChannel`, `SlackUsers` |
| `discriminant` | `×` branch label (only for `×` children) | `ById`, `ByName`, `BySearch` |

## Verb Derivation from Operator

| Operator | Context | Verb | Rationale |
|----------|---------|------|-----------|
| `×` node | Root of choice subtree | `identify` | Choosing which path to take |
| `×` branch | Child of `×` | `resolve` | Executing one specific resolution path |
| `→` chain | Standalone pipeline | `export`, `process` | Producing an artifact or transformation |
| `∧` group | Parallel collection | `fetch`, `gather` | Retrieving multiple things concurrently |
| `↻` | Repetition over collection | base verb (plural entity) | Orchestrates repeated action; plural signals collection I/O |
| Leaf (synthesis) | Derives new data | `infer`, `synthesize`, `build` | Creating data from analysis |
| Leaf (API call) | Calls external system | `call`, `fetch` | Side-effectful retrieval |
| Leaf (write) | Writes to external system | `write`, `propagate` | Side-effectful output |

## Domain Entity Derivation from Output Type

Read the output data shape of the tree node. Strip state-adjective prefixes (`Resolved`, `Enriched`, `Synthesized`) to get the domain noun. For `↻` nodes, pluralize since input/output are collections.

| Output Type | Domain Entity |
|-------------|--------------|
| `ResolvedChannel` | `SlackChannel` |
| `ChannelMember` | `SlackUser` → `SlackUsers` (plural for `↻`) |
| `list of DRIAssignment` | `DRIAssignments` |
| `SlackExportDocument` | `SlackThread` |
| `ContactFieldPair` | `SpreadsheetCells` |
| `Message with replies` | `ThreadReplies` (already plural) |

## Discriminant Derivation from `×` Branch Label

Only `×` children get a discriminant. Convert the branch label to `By` + noun form.

| Branch Label | Discriminant |
|---|---|
| `ChannelIdProvided` | `ById` |
| `ChannelNameProvided` | `ByName` |
| `SearchRequired` | `BySearch` |
| `MessageContentIndicatesRole` | `FromMessageContent` |
| `EmailDomainMatchesCompany` | `FromEmailDomain` |

## Applied Examples

### `×` node (choice dispatcher)

```
Tree: IdentifyChannel (× node, output: ResolvedChannel)

× node
  verb = "identify" (× at root)
  entity = "SlackChannel" (ResolvedChannel → SlackChannel)
  discriminant = none (dispatcher)
  → identifySlackChannel

× branch 0: ChannelIdProvided
  verb = "resolve" (child of ×)
  entity = "SlackChannel"
  discriminant = "ById"
  → resolveSlackChannelById

× branch 1: ChannelNameProvided
  verb = "resolve"
  entity = "SlackChannel"
  discriminant = "ByName"
  → resolveSlackChannelByName
```

### `↻` node (repetition — plural entity, no `Each`)

```
Tree: ResolveUserProfiles (↻ node, output: ChannelMember)

↻ node
  verb = "resolve" (base verb)
  entity = "SlackUsers" (ChannelMember → SlackUser, pluralized for collection)
  → resolveSlackUsers
```

### `→` root (pipeline)

```
Tree: ExportAndPropagate (→ root, output: SlackExportDocument)

→ root
  verb = "export" (pipeline producing artifact)
  entity = "SlackThread"
  → exportSlackThread
```

### Synthesis leaf

```
Leaf: InferOrgFromEmail

  verb = "infer" (synthesis leaf)
  entity = "Org"
  discriminant = "FromEmail"
  → inferOrgFromEmail
```

### Write leaf

```
Tree: PropagateToSpreadsheet (→ sub-pipeline, output: SpreadsheetCellsUpdated)

  verb = "propagate" (write leaf)
  entity = "SpreadsheetCells"
  → propagateSpreadsheetCells
```

## Function Registry Derivation Rule

Every leaf and named sub-process in the process tree becomes a function. Operator nodes become composition patterns:

- `×` node → 1 dispatcher function + N branch functions
- `→` chain → function composition (pipeline)
- `∧` group → parallel executor
- `↻` → map/fold (plural entity name)
- Leaf → pure function or effectful function (based on side-effects)

### Example Registry

| # | Function | Operator | Input | Output |
|---|----------|----------|-------|--------|
| 1 | `exportSlackThread` | `→` root | `ChannelInput + SavePath` | `SlackExportDocument` |
| 2 | `identifySlackChannel` | `×` node | `ChannelInput` | `ResolvedChannel` |
| 3 | `resolveSlackChannelById` | `×` branch | `string` | `ResolvedChannel` |
| 4 | `resolveSlackChannelByName` | `×` branch | `string` | `ResolvedChannel` |
| 5 | `fetchSlackChannelMembers` | `→` leaf | `ChannelId` | `list of UserId` |
| 6 | `resolveSlackUsers` | `↻` node | `list of UserId` | `list of ChannelMember` |
| 7 | `inferOrgFromEmail` | leaf | `Email` | `Org` |
| 8 | `fetchThreadReplies` | `↻` node | `list of Message` | `list of Message (enriched)` |
| 9 | `propagateSpreadsheetCells` | `→` sub-pipeline | `Members + EventDate` | `CellsUpdated` |
