---
summary: Template for default combined product and implementation planning.
type: playbook
read_when:
  - Creating a plan for normal-sized requests.
code_paths: []
---

# Combined Product + Implementation Plan

## Scope
- Problem:
- In scope:
- Out of scope:
- User impact:

## Approach
- Technical approach:
- Touched systems/components/interfaces:
- Constraints:
- Risks and mitigations:

## Execution Mode
- Mode: `Sequential` (default) or `Parallel` (explicit user approval required)
- Recommendation (if suggesting parallel):
- Approval status:

## Parallel Workstreams (Only if approved)
- Stream 1 scope + owned files/interfaces:
- Stream 2 scope + owned files/interfaces:
- Branch/worktree mapping:
- Shared contracts/dependencies:
- Integration order:

## Checklist
- [ ] Requirements clarified
- [ ] Affected systems/components/interfaces identified
- [ ] Execution mode and approval status recorded
- [ ] Implementation steps defined
- [ ] Parallel stream mapping and integration order defined (if parallel approved)
- [ ] Test commands and pass criteria defined
- [ ] Documentation updates identified
- [ ] Done criteria defined
- [ ] Plan archived to `plans/archive/` on completion or cancellation

## Testing Plan
- Targeted checks:
- Full suite before push: `<repo-verify-cmd>`
- Regression tests:

## Documentation Impact
- Docs to update:
- New docs required:
- Metadata/frontmatter updates needed:

## Done Criteria
- Functional outcomes:
- Quality gates:
- Formal plan archived from `plans/` to `plans/archive/`

## Progress Log
- `YYYY-MM-DD HH:MM` - Planned: <what was planned>
- `YYYY-MM-DD HH:MM` - Executed: <what changed>
- `YYYY-MM-DD HH:MM` - Verified: <tests/docs validated>
- `YYYY-MM-DD HH:MM` - Archived: <plan moved to plans/archive/...>`
- `YYYY-MM-DD HH:MM` - Next: <next step or blocker>
