# Eval: Dynamic Logging Location (FUTURE - Requires Slow Variant)

**Status:** Documented design, awaiting Epic 3 (Slow Variant) implementation

**Related:** GitHub Issue #11, User Story 2.3

**Purpose:** Verify that test logs are colocated with the skill being tested, not centralized in testing-skills-with-subagents directory.

## Eval Design (To be implemented after Slow Variant exists)

This eval will use the slow variant (worktree-based testing) to validate logging location behavior.

### Baseline Scenario (RED Phase)

**Test:** citation-manager skill with old logging behavior
- Invoke testing-skills-with-subagents on citation-manager
- Logs created at: `.claude/skills/testing-skills-with-subagents/logs/YYYYMMDD-HHMMSS-citation-manager/`
- **Result:** FAIL - logs in wrong location

**Expected log structure:**

```
.claude/skills/testing-skills-with-subagents/logs/YYYYMMDD-HHMMSS-citation-manager/
├── scenario-01-baseline.log
├── scenario-02-baseline.log
└── session-metadata.json
```

### Green Scenario (GREEN Phase)

**Test:** citation-manager skill with fixed logging behavior
- Invoke testing-skills-with-subagents on citation-manager (with fix applied)
- Logs created at: `.claude/skills/citation-manager/logs/YYYYMMDD-HHMMSS-test-session/`
- **Result:** PASS - logs colocated with tested skill

**Expected log structure:**

```
.claude/skills/citation-manager/logs/YYYYMMDD-HHMMSS-test-session/
├── scenario-01-baseline.log
├── scenario-02-baseline.log
└── session-metadata.json
```

## Why This Requires Slow Variant

- Slow variant uses worktrees + full isolation
- Enables testing skill behavior with/without fixes
- Provides filesystem evidence of log location
- Prevents test pollution from concurrent runs

## Next Steps

1. Implement Story 2.3 (dynamic logging location)
2. Create this eval using slow variant
3. Add to pre-deployment validation suite
4. Reference in skill documentation

## Running This Eval (Once Slow Variant Exists)

```bash
# Use slow variant to test fast variant logging behavior
invoke testing-skills-with-subagents skill
→ Choose: Slow variant
→ Choose: Run eval scenario
→ Select: logging-location-dynamic

# Verify logs appear in citation-manager's logs directory
ls .claude/skills/citation-manager/logs/
```
