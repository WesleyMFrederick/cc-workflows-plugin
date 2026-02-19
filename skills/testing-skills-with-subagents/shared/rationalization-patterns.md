# Rationalization Patterns for Skill Testing

## Overview

Common rationalization categories and counters extracted from both fast and slow testing variants. Use these patterns to identify when agents are trying to bypass skill requirements.

## Common Rationalization Categories

### 1. "I already tested manually"

**Pattern:** Agent claims manual testing is equivalent to automated tests or TDD compliance.

**Reality:** Manual testing doesn't provide regression protection, doesn't enforce design discipline, and doesn't prevent future breakage.

**Counter in skill:** "Manual testing and automated tests serve different purposes. Manual testing validates current behavior, automated tests prevent future regressions."

### 2. "Tests after achieve same goals"

**Pattern:** Agent claims writing tests after implementation achieves the same result as TDD.

**Reality:** Tests-after don't drive design, don't prevent over-engineering, and don't catch design flaws early.

**Counter in skill:** "TDD is not about having tests, it's about tests driving design. Tests-after validate implementation, tests-first guide design."

### 3. "Deleting work is wasteful"

**Pattern:** Agent claims deleting implementation to start with TDD is a waste of time/effort.

**Reality:** Sunk cost fallacy. Keeping flawed implementation costs more in maintenance than rewriting with proper design.

**Counter in skill:** "Sunk cost is not a reason to keep poorly designed code. Delete means delete. Start fresh with tests first."

### 4. "Being pragmatic not dogmatic"

**Pattern:** Agent frames rule-following as dogmatism and rule-breaking as pragmatism.

**Reality:** Pragmatism means choosing proven practices that reduce long-term cost. TDD is pragmatic.

**Counter in skill:** "Pragmatism means following practices with proven ROI. TDD reduces bugs and maintenance costs. That's pragmatic, not dogmatic."

### 5. "Keep as reference while writing tests"

**Pattern:** Agent wants to keep implementation code visible while writing tests "from scratch."

**Reality:** Looking at implementation while writing tests leads to implementation-driven tests, not behavior-driven tests.

**Counter in skill:** "Delete means delete. Don't keep as reference, don't adapt it, don't look at it. If you need to reference it, you're testing the implementation, not the behavior."

### 6. "I'm following the spirit not the letter"

**Pattern:** Agent claims to follow the intent while violating the explicit rule.

**Reality:** Spirit vs letter is a false dichotomy. Following the letter IS following the spirit.

**Counter in skill:** "Violating the letter is violating the spirit. The rule exists because the spirit requires it. There is no 'spirit without letter.'"

### 7. "This case is different because..."

**Pattern:** Agent invents special circumstances to justify exception.

**Reality:** Every case feels different. Rules exist to prevent rationalization of "special cases."

**Counter in skill:** "No exceptions. If the rule says X, do X. Special circumstances are when rules matter most."

### 8. "I'll just do this one thing first"

**Pattern:** Agent wants to do "quick" action before following proper workflow.

**Reality:** "One thing first" becomes implementation before tests, which violates TDD.

**Counter in skill:** "Check for skills BEFORE doing anything. One thing first = skipping workflow."

## Red Flag Language Patterns

Words and phrases that signal rationalization in progress:

- **Justification phrases:**
  - "Just this once"
  - "Normally I would but..."
  - "In this case it's different"
  - "Being pragmatic means..."
  - "The spirit of the rule is..."

- **Minimizing phrases:**
  - "It's only a small change"
  - "This is just a simple..."
  - "Quick fix before..."
  - "I'll just..."

- **False equivalence:**
  - "X achieves the same goal as Y"
  - "Tests after work just as well"
  - "Manual testing is equivalent"

- **Sunk cost appeals:**
  - "I already spent X hours"
  - "Deleting this is wasteful"
  - "All this work for nothing"

## Meta-Testing Questions

When evaluating test results, ask:

1. **Did the agent rationalize or follow the skill?**
   - If rationalized: Which category above?
   - If followed: What pressure was most effective?

2. **Which pressures were most effective?**
   - Time pressure (deadlines, emergencies)
   - Sunk cost pressure (hours invested)
   - Authority pressure (senior says skip it)
   - Exhaustion pressure (end of day)
   - Economic pressure (job, promotion)
   - Social pressure (looking dogmatic)

3. **What loopholes remain?**
   - New rationalizations not covered above
   - Variations on existing patterns
   - Combinations that weren't tested

4. **Does the skill explicitly counter this rationalization?**
   - If yes: Is the counter prominent enough?
   - If no: Add explicit counter to skill

## Using This Document

**During RED phase (baseline testing):**
- Document agent rationalizations verbatim
- Categorize using patterns above
- Identify which patterns appear repeatedly

**During GREEN phase (writing skill):**
- Add explicit counters for each pattern observed
- Use counter-argument templates from above
- Make red flag phrases prominent

**During REFACTOR phase (closing loopholes):**
- Check if new rationalizations fit existing categories
- Add new categories if patterns emerge
- Update skill with explicit negations

**During meta-testing:**
- Ask agent which rationalization they used
- Verify skill has explicit counter
- Confirm counter is prominent/clear enough
