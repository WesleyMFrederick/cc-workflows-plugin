---
name: git-create-commit-skill
description: Use when creating git commits - mandates commits format with required scopes for all new commits, provides scope discovery from codebase structure, and prevents rationalization under pressure (emergency, fatigue, ambiguity)
---

# Git Commits

## Overview

**Mandatory discipline for ALL new git commits.** Every commit MUST follow commit format with a required scope, discovered from codebase structure.

**Core Principle:** Consistent, machine-parsable commit messages enable automated change-log generation, semantic versioning, and clear project history. Commit messages are **names for changes** and follow the same self-contained naming principles as code identifiers.

> [!attention] **The Iron Law**
> NO COMMIT WITHOUT TYPE, SCOPE, DESCRIPTION

This applies to ALL commits: simple fixes, typos, documentation, emergencies - everything. No exceptions.

## When to Use

**MANDATORY:**
- Before creating ANY new git commit
- When Bash tool executes `git commit` command

**OPTIONAL:**
- When revising past commits for consistency

**FORBIDDEN:**
- Bypassing format "just this once"
- Skipping scope because "it doesn't fit"
- Using vague scopes like "misc" or "various"

## Format Structure

### Required Format

```text
<type>(<scope>): [US#.#] [Task #.#.#] <description>

[optional body]

[optional footer(s)]
```

**Note:** User story and task numbers are included in the description line when available. If no task number exists, include only the user story number. If working without user stories, omit the bracketed identifiers.

### Supported Types (Extended Common Set)

| Type | Purpose | SemVer Impact |
|------|---------|---------------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | - |
| `chore` | Maintenance (deps, configs) | - |
| `refactor` | Code restructure, no behavior change | - |
| `test` | Test additions/modifications | - |
| `perf` | Performance improvements | PATCH |
| `ci` | CI/CD pipeline changes | - |
| `build` | Build system changes | - |
| `style` | Code formatting, whitespace | - |

**Breaking Changes:** Include `BREAKING CHANGE:` footer (triggers MAJOR)

## Scope Discovery Process

**THE PRIMARY FAILURE MODE:** Agents abandon entire format when scope is ambiguous. This section prevents that.

### The Mandatory Scope Rule

> [!attention] **Every commit MUST include a scope.**

### How to Discover Scope

1. **Run scope discovery commands:**

   ```bash
   git status
   git diff --name-only
   ```

2. **Identify patterns in changed files:**
   - Top-level directories: `src/`, `docs/`, `tests/`
   - Module names: `auth`, `api`, `ui`, `database`
   - Component names: `LoginForm`, `UserProfile`
   - Package names: `@workspace/package-name`

3. **Apply the Primary Scope Rule:**
   - **Single module:** Use that module name
   - **Multiple modules, one area:** Use area name
   - **Cross-cutting changes:** Pick the PRIMARY changed layer
   - **Truly global:** Use `core`, `config`, or `global`
   - **Can't decide in 30 seconds:** Use top-level directory from first changed file

### Scope Selection Examples

| Changed Files | Correct Scope | Reasoning |
|--------------|---------------|-----------|
| `src/auth/*.ts` only | `auth` | Single module |
| `docs/README.md` | `readme` | Specific doc file |
| `.github/workflows/*` | `workflows` or `ci` | CI area |
| Multiple test files | `integration` or `unit` | Test type |
| `src/auth/form.tsx`, `src/api/auth.ts`, `src/utils/validate.ts` | `auth` | **Primary** layer is auth, even though utils touched |
| `src/*.ts` (many files, no pattern) | `core` | Global/core changes |

### The 30-Second Rule

**If you can't decide on scope after 30 seconds:**
1. Pick the directory name of the first changed file
2. Or use the most specific layer touched
3. **Never** skip scope because it's ambiguous

**Any scope is better than no scope.** Imperfect scope > abandoned format.

## Description Quality (Self-Contained Naming)

Commit descriptions follow the project's **Self-Contained Naming Principles** - they are names for changes:

### Rules

1. **Descriptive Labels:** The `<type>(<scope>): <description>` format distinguishes operation type, system scope, and outcome
2. **Immediate Understanding:** Anyone should understand what the commit does without reading the diff
3. **Confusion Prevention:** Be specific enough to eliminate ambiguity

### Description Guidelines

- Include user story and task numbers when available: `[US#.#] [Task #.#.#]`
- Focus on WHAT and WHY, not HOW
- Complete the sentence: "This commit will..."
- Be specific: "add" not "update", "fix" not "change"
- Keep under 72 characters (excluding US/task identifiers)
- Lowercase first word (after US/task identifiers if present, or after type if not)
- No period at end

**Examples:**
- ❌ `fix(auth): fix bug` - Too vague
- ❌ `fix(auth): update code` - What code? What changed?
- ✅ `fix(auth): prevent null pointer on missing OAuth state`
- ✅ `feat(api): add email validation to login endpoint`
- ✅ `feat(jact): [US2.3] [Task 2.3.1] implement link extraction from markdown`
- ✅ `docs(readme): [US1.2] add installation instructions for CLI`

## Footer Management

### Footer Format

One blank line after body (or description if no body), then footers.

### Required Footer Types

**1. AI Coding Assistant Attribution (ALWAYS include):**

```text
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**2. Breaking Changes (when applicable):**

```text
BREAKING CHANGE: description of what broke and migration path
```

**3. Issue/Task References (when applicable):**

```text
Refs: #123
Closes: #456
Fixes: #789
```

**4. Review/Approval Metadata (when applicable):**

```text
Reviewed-by: Name <email>
Approved-by: Name <email>
```

### Footer Assembly Order

1. Breaking changes first (if any)
2. Issue references (if any)
3. Review metadata (if any)
4. Claude attribution (always last)

### Complete Example

```text
feat(auth)!: add OAuth 2.0 support

Replaces legacy session-based auth with OAuth 2.0 flow.
Adds Google and GitHub providers.

BREAKING CHANGE: Session middleware removed, use OAuth tokens
Closes: #234
Reviewed-by: Tech Lead <lead@example.com>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## The Iron Law - Enforcement

> [!attention] ALL NEW COMMITS MUST FOLLOW COMMIT FORMAT

**This applies to:**
- "Simple" commits (typos, formatting)
- "Quick fixes"
- "Just updating a comment"
- Commits under time pressure
- End-of-day commits
- Emergency hotfixes
- Documentation changes
- Configuration changes

**No exceptions. Ever.**

**Violating the letter of the rules is violating the spirit of the rules.**

## Red Flags - STOP Immediately

If you're thinking any of these, STOP and apply the format correctly:

- "This commit is too simple for the format"
- "I'll fix the message in the next commit"
- "The format doesn't add value here"
- "Following the spirit, not the letter"
- "Time pressure makes this exception okay"
- **"Scope doesn't fit / is ambiguous"** ← Primary failure mode
- "Scope adds minimal value"
- "Can't decide on scope"
- Using vague scopes like "misc", "various", "other"
- Skipping scope entirely
- Vague descriptions like "fix bug" or "update code"
- **"US/task numbers are just context, put them in body"** ← Common rationalization
- **"US/task numbers make description too long"** ← They don't count toward 72-char limit
- "Description should be purely technical without US numbers"

**All of these mean: Stop. Apply the format correctly with a specific scope and US/task numbers in description.**

## Common Rationalizations

These are captured from real baseline testing - agents use these exact rationalizations under pressure:

| Rationalization | Reality |
|----------------|---------|
| "Too simple for commit format" | Simple commits still need clear history. Takes 5 seconds. |
| "I'll clean it up later" | Later never comes. Do it now. |
| "Scope doesn't matter for docs" | Docs have structure too. Use appropriate scope (readme, api-docs, guides). |
| "Emergency hotfix, no time" | Hotfixes especially need clear documentation. 10 seconds won't delay deployment. |
| "Following the spirit" | The letter IS the spirit. Format enables tooling and immediate understanding. |
| "Description is obvious from diff" | People read commits without diffs. Make it self-contained. |
| **"Cross-cutting change, scope is arbitrary"** | **Pick the PRIMARY layer. Auth + API + utils? Primary is auth. Use `auth`.** |
| **"Scope adds minimal value"** | **Scopes enable filtering, navigation, and understanding. Mandatory for tooling.** |
| **"Can't decide scope after thinking"** | **Use the 30-Second Rule: pick first file's directory or most specific layer.** |
| "Multiple layers, can't pick one" | **Primary Scope Rule: pick the layer that changed MOST or is MOST important to the feature.** |
| **"US/task numbers are context, not metadata"** | **Context belongs in body. Identifiers belong in description. US/task numbers are identifiers for traceability.** |
| **"Description should be purely technical"** | **US/task numbers ARE technical metadata. They link commits to requirements for impact analysis.** |

## Common Mistakes

### Mistake 1: Abandoning Format When Scope Unclear

**Wrong:**

```text
Add email validation to login flow
```

**Right:**

```text
feat(auth): add email validation to login flow
```

**Fix:** Even if scope seems ambiguous (auth? validation? ui?), pick the PRIMARY one. In this case, the primary feature is authentication, so use `auth`.

### Mistake 2: Vague Scope

**Wrong:**

```text
fix(misc): update validation
```

**Right:**

```text
fix(auth): prevent null pointer in email validation
```

**Fix:** "misc" and "various" are red flags. Use the specific module or component.

### Mistake 3: Missing Scope Entirely

**Wrong:**

```text
docs: update README
```

**Right:**

```text
docs(readme): add installation instructions
```

**Fix:** Scopes are MANDATORY. For docs, use the specific doc file or section.

### Mistake 4: Capitalized Description

**Wrong:**

```text
fix(auth): Fix OAuth bug
```

**Right:**

```text
fix(auth): fix OAuth null pointer error
```

**Fix:** Description should be lowercase (except proper nouns).

### Mistake 5: US/Task Numbers in Body Instead of Description

**Wrong:**

```text
feat(jact): implement link extraction from markdown

Adds LinkExtractor component for US2.3.
Part of Task 2.3.1 implementation.
```

**Right:**

```text
feat(jact): [US2.3] [Task 2.3.1] implement link extraction from markdown

Adds LinkExtractor component to extract and parse markdown links from
content for validation and content extraction phases.
```

**Fix:** US/task numbers are identifiers that belong in the description line, not narrative context in the body. Check implementation plans, user story documents, or commit context for US/task numbers before committing.

## Submodule Propagation

> [!attention] **Dirty submodules = commit inside first, push to local hub, then commit pointer in parent. Always. One operation.**

### Architecture: Local Hub-and-Spoke

The `.claude` submodule uses a **local hub** topology:

```text
cc-workflows-plugin (LOCAL HUB)
  ├── origin: local path (fast, default)
  ├── github: https://github.com/... (backup, push manually)
  │
  ├── jact/.claude pulls/pushes here
  └── other-project/.claude pulls/pushes here
```

**Remotes in each consumer's `.claude/` submodule:**
- `origin` → local path to `cc-workflows-plugin` (default for push/pull)
- `github` → GitHub URL (backup only, push explicitly when desired)

### The Rule

When `git status` in the parent repo shows a modified submodule (e.g., `.claude`), you MUST propagate commits bottom-up:

1. **Detect:** Run `git status` in parent repo. Look for modified submodules (lines like `M .claude`)
2. **Commit inside submodule:** Stage changes, commit using this skill's full format
3. **Push submodule to local hub:** Detect remote name via `git -C .claude remote -v` (may be `origin`, `origin-local`, etc.), then push: `git -C .claude push <remote> main`
4. **Commit pointer in parent:** Stage the submodule path and commit the updated pointer

**Even when the submodule working tree is clean**, always check for unpushed commits:
`git -C .claude log origin/main..HEAD --oneline`
If unpushed commits exist, execute Step 3 (push to local hub). Hooks or prior sessions may have committed inside the submodule without pushing.

**This is ONE atomic operation from the user's perspective.** Do NOT stop between steps to ask. Do NOT commit only the parent pointer without first committing inside the submodule. Do NOT push to GitHub unless explicitly requested — `origin` is the local hub.

### Workflow

```text
Parent repo: git status shows " M .claude"
  ├─ Step 1: git -C .claude status          (discover submodule changes)
  ├─ Step 2: git -C .claude add <files>     (stage inside submodule)
  ├─ Step 3: git -C .claude commit          (commit inside submodule, full format)
  ├─ Step 4: git -C .claude push <remote> main (detect remote name first, push to LOCAL hub, NOT GitHub)
  ├─ Step 5: git add .claude                (stage updated pointer in parent)
  └─ Step 6: git commit                     (commit pointer update in parent, full format)
```

### Edge Case: Hub Has Newer Commits

When files are edited directly in the hub repo (e.g., editing a skill in `cc-workflows-plugin/` rather than through a consumer's `.claude/` submodule), the submodule's push will be rejected because the hub is ahead.

**Fix:** Pull with rebase inside the submodule before pushing:

```text
  ├─ git -C .claude pull --rebase <remote> main   (rebase onto hub's new commits)
  └─ git -C .claude push <remote> main             (now succeeds)
```

**Common trigger:** Editing skill/agent files via their hub repo path instead of the submodule path. Both paths point to the same content, but only one updates the hub's HEAD directly.

### Pushing to GitHub (Backup Only)

GitHub is backup. Push explicitly when desired:

```bash
# From any consumer's .claude/ or from the standalone hub:
git push github main
```

Do NOT push to GitHub automatically. The user will say "push to GitHub" or "back up" when they want it.

### Commit Message for Pointer Updates

Parent repo commits that only update a submodule pointer use scope `deps` or the submodule name:

```text
chore(deps): update .claude submodule with <summary of submodule changes>
```

### Red Flags - STOP Immediately

- "I'll just commit the parent pointer" → WRONG. Submodule has uncommitted changes.
- "Let me ask if they want to commit the submodule" → WRONG. Propagation is automatic.
- "The submodule changes are separate" → WRONG. If user asked to commit, commit everything.
- "Let me push to GitHub" → WRONG. Push to `origin` (local hub). GitHub is `github` remote, backup only.
- "I should push parent to GitHub too" → WRONG. Not unless user asks.
- "Working tree is clean, nothing to do" → WRONG. Check for unpushed commits with `log origin/main..HEAD`.

## Integration with Bash Tool

**Steps — execute in order, no skipping:**

1. Run `git status` to see changed files
2. Run `git diff --name-only` to confirm file list
3. Pick type (`feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`, `ci`, `build`, `style`)
4. Pick scope using the Primary Scope Rule (30-second max)
5. Use the **Write tool** to create `/tmp/commit-msg.txt` with this content:

```
<type>(<scope>): <description>

<optional body — explain why, not what>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

6. Commit using the file:

```bash
git commit -F /tmp/commit-msg.txt
```

**Rules for the message file:**
- Subject line: lowercase after scope, no period, under 72 chars
- Blank line between subject and body
- Blank line between body and footers
- `Co-Authored-By: Claude <noreply@anthropic.com>` — exact string, no model version
- If working within user stories: add `[US#.#] [Task #.#.#]` to subject line before description
- If no user stories: omit the brackets entirely

## Quick Reference

| Element | Requirement | Example |
|---------|-------------|---------|
| **Type** | REQUIRED | `feat`, `fix`, `docs` |
| **Scope** | REQUIRED | `auth`, `api`, `readme` |
| **US/Task IDs** | When available | `[US2.3] [Task 2.3.1]` |
| **Description** | REQUIRED, lowercase, <72 chars | `add email validation` |
| **Body** | Optional | Explain why, not what |
| **Breaking change** | When applicable | `BREAKING CHANGE:` footer |
| **Issue refs** | When applicable | `Closes: #123` |
| **Attribution** | ALWAYS | Claude Code footer |

## The Bottom Line

> [!attention] **Commit format is a discipline, not a suggestion.**

Like test-driven development, it feels like overhead until you experience the benefits: automated changelogs, semantic versioning, clear history, easy filtering, tool compatibility.

**The scope requirement is non-negotiable** because it's where agents rationalize away the entire format.

When in doubt: Pick a scope in 30 seconds and move on. Any scope > no scope.
