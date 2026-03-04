---
summary: Template for stage 2 implementation planning in complex requests.
type: playbook
read_when:
  - Converting approved product direction into executable implementation work.
code_paths: []
---

# Implementation Plan (Complex Request, Stage 2)

## Architecture/Design Changes
- Systems/components affected:
- Interface/data model changes:

## Execution Mode
- Mode: `Sequential` (default) or `Parallel` (explicit user approval required)
- Recommendation (if suggesting parallel):
- Approval status:

## Sequencing
- Phase 1:
- Phase 2:
- Phase 3:

## Parallel Streams (Only if approved)
- Stream 1 scope + owned files/interfaces:
- Stream 2 scope + owned files/interfaces:
- Branch/worktree mapping:
- Cross-stream dependencies/handoffs:
- Integration order:

## Migration/Rollout
- Migration steps:
- Rollback plan:

## Checklist
- [ ] Architecture changes defined
- [ ] Execution mode and approval status recorded
- [ ] Migration and rollback defined
- [ ] Parallel stream mapping and integration order defined (if parallel approved)
- [ ] Test matrix and commands defined
- [ ] Documentation updates mapped
- [ ] Release/rollout criteria defined

## Verification
- Targeted checks:
- Full suite: `<repo-verify-cmd>`
- Integration checks (if parallel approved):
- Post-migration checks:

## Progress Log
- `YYYY-MM-DD HH:MM` - Step: <done>
- `YYYY-MM-DD HH:MM` - Verification: <result>
- `YYYY-MM-DD HH:MM` - Blocker/decision: <details>
