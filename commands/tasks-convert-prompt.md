---
description: "Decompose query into reviewable task list that claude code converts into ToDo tasks"
argument-hint: prompt
---

# Return Micro Intents

## Usage
- `/tasks-convert-prompt "analyze shopping cart feature"` - Decompose query into reviewable task list

**Extract** the _domain_, _category_, and _primary focus_ of the **user's request**. Using the extracted entities as a guide, **deconstruct** the **user's request query** into _independent, atomic_ **sub-tasks**. Ensure full coverage of the original intent while maintaining independence between tasks.

## Input Validation
If no query is provided ($1 is empty), respond with: "Error: Please provide a query to analyze. Usage: /return-micro-intents '<query>'"

<user-request-query-input>
$1
</user-request-query-input>

## Task Naming Rules

Each task name MUST follow Self-Contained Naming Principles:

- **Descriptive**: The name alone must signal purpose, scope, and outcome without needing lookup
- **Immediately Understandable**: Any human or AI must understand the task's purpose from the name alone
- **Confusion-Preventing**: Provide enough detail to eliminate ambiguity about what the task involves
- Names should be full sentences starting with an action verb, including context about what, why, and scope

**Good**: "Review existing e-commerce website codebase to understand current component architecture and identify integration points for new shopping cart feature"

**Bad**: "gather context by reviewing project files"

## Output Format

### Header
Present the extracted entities first:

```
**Domain**: [domain] | **Category**: [category] | **Primary Focus**: [focus]
```

### Task Table
Present decomposed tasks in a box-drawing table with three columns: #, Type, and Task.

- **Type column**: `EXPL` for explicit intent, `IMPL` for implicit intent
- **Task column**: Self-contained task name (truncate to fit table width if needed, but preserve meaning)
- Generate reasoning internally for each task but do NOT display it — reasoning surfaces later in TodoWrite descriptions

```
┌─────┬────────┬───────────────────────────────────────────────────────────────────┐
│  #  │  Type  │ Task                                                              │
├─────┼────────┼───────────────────────────────────────────────────────────────────┤
│  1  │ IMPL   │ Task name here                                                    │
│  2  │ EXPL   │ Task name here                                                    │
└─────┴────────┴───────────────────────────────────────────────────────────────────┘
```

## Feedback Loop

After presenting the table, prompt:

**Would you like me to:**
1. Convert to tasks and implement tasks without stopping
2. Update tasks (share your changes)

**Option 1 behavior**: For each task in the table, create a TaskCreate entry with `subject` (full untruncated task name), `description` (internally generated reasoning), and `activeForm` (present continuous form). Then begin executing tasks in order without stopping.

**Option 2 behavior**: Wait for the user to specify changes (remove tasks by number, rename, reorder, add new ones). Apply changes, present the updated table, then prompt again with the same two options.

## Examples

<example>
**Query**: "I need to add a shopping cart feature to our e-commerce website for the upcoming Black Friday sale."

**Domain**: Software Development | **Category**: E-commerce | **Primary Focus**: Shopping cart feature implementation

┌─────┬────────┬───────────────────────────────────────────────────────────────────────────┐
│  #  │  Type  │ Task                                                                      │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  1  │ IMPL   │ Review existing e-commerce codebase to identify architecture + integration │
│     │        │ points for new shopping cart feature                                       │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  2  │ IMPL   │ Elicit shopping cart requirements including payment, guest checkout, and   │
│     │        │ UI expectations to focus on highest-impact needs                           │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  3  │ IMPL   │ Research technology stack compatibility, third-party payment integrations, │
│     │        │ and existing codebase patterns based on user requirements                  │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  4  │ IMPL   │ Synthesize findings and present to user for validation before proceeding   │
│     │        │ to implementation planning                                                 │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  5  │ IMPL   │ Create product requirements document section by section with ongoing       │
│     │        │ elicitation, research, and sense-making                                    │
└─────┴────────┴───────────────────────────────────────────────────────────────────────────┘

**Would you like me to:**
1. Convert to tasks and implement tasks without stopping
2. Update tasks (share your changes)
</example>

<example>
**Query**: "Help me analyze patient readmission patterns to reduce our hospital's 30-day readmission rates."

**Domain**: Healthcare Analytics | **Category**: Quality Improvement | **Primary Focus**: Patient readmission pattern analysis and reduction

┌─────┬────────┬───────────────────────────────────────────────────────────────────────────┐
│  #  │  Type  │ Task                                                                      │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  1  │ IMPL   │ Assess hospital's current data infrastructure and available patient data   │
│     │        │ sources for readmission analysis                                           │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  2  │ IMPL   │ Clarify objectives and measurable success metrics for readmission          │
│     │        │ reduction including target percentages and priority populations             │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  3  │ IMPL   │ Verify HIPAA compliance and patient privacy requirements before            │
│     │        │ accessing or processing patient health data                                │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  4  │ EXPL   │ Extract and clean patient data including demographics, diagnoses, length   │
│     │        │ of stay, and readmission records into unified dataset                      │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  5  │ EXPL   │ Identify statistical patterns and risk factors associated with 30-day      │
│     │        │ hospital readmissions                                                      │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  6  │ IMPL   │ Develop predictive models to identify high-risk patients before discharge  │
│     │        │ based on discovered readmission patterns                                   │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  7  │ IMPL   │ Create actionable clinical recommendations for staff and administration    │
│     │        │ based on analysis findings                                                 │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────┤
│  8  │ IMPL   │ Design monitoring and evaluation framework to track readmission rate       │
│     │        │ improvements and validate implemented changes                              │
└─────┴────────┴───────────────────────────────────────────────────────────────────────────┘

**Would you like me to:**
1. Convert to tasks and implement tasks without stopping
2. Update tasks (share your changes)
</example>
