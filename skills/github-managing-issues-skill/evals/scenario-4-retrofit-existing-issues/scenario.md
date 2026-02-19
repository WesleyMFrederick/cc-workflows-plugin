# Scenario 4: Retrofit Existing Issues to Match Standard Format

**Test objective**: Verify agent systematically retrofits existing issues using reference template, preserves existing content, and adds missing sections.

## Pressure Scenario

IMPORTANT: This is a real scenario. You must choose and act.

You've been asked to audit all issues with label `area:citation-manager`. The PM says:
"We need all these issues to follow our standard format. Use issue #62 as the reference. Some issues already have partial AC, some have none. Make sure they all match our standard."

You check and find 6 open issues:
- #14: "Extract citation links" - has description, no AC/DoD
- #16: "Add validation for broken links" - has AC but incomplete DoD
- #27: "Refactor parser" - minimal description, no AC/DoD
- #36: "Fix header extraction" - has description and AC, missing DoD
- #40: "Support block anchors" - empty description, no AC/DoD
- #41: "Improve error messages" - has all sections but wrong format

Reference issue #62 has:
- Complete 8-section structure (Summary, Background, Problem, etc.)
- Type-specific AC/DoD (feature vs bug vs refactor)
- Cross-references to related issues

## Response Format

What would you do to handle this request?

Give a 50-250 word explanation of your approach.

Give a DETAILED todo list, complete with which tools you would call,
to execute your plan to handle the request.

## Baseline Expectations (RED - without skill)

**Expected violations**:

- Manually views each issue one-by-one instead of batch fetch
- Rationalizes: "Issues already look fine, they have descriptions"
- Skips adding AC/DoD: "Not needed for refactors"
- Copies #62 verbatim without adapting to issue type
- Overwrites existing content instead of preserving it
- Doesn't cross-reference related issues
- Adds generic AC instead of type-specific (bug vs feature vs refactor)

## Green Expectations (with skill)

**Expected compliance**:

- Uses `gh issue list --label area:citation-manager --json` for batch fetch
- Views reference issue #62 to understand template
- For each issue:
  - Preserves existing description/AC/DoD content
  - Adds missing sections only
  - Adapts AC/DoD to issue type (bug/feat/refactor)
  - Adds cross-references where relevant
- Uses `gh issue edit` with multi-line content for updates
- Verifies all 6 issues now match standard format
