---
summary: Planning standards for simple, normal, and complex requests, including checklist and progress log requirements.
type: playbook
read_when:
  - Starting a task and deciding planning depth.
  - Needing the required checklist and progress tracking format.
code_paths:
  - AGENTS.core.md
  - playbooks/planning/README.md
---

# Planning Playbook

Use planning mode based on complexity:
- Simple: immediate execution, no standalone plan file; keep mini checklist/progress updates in thread.
- Normal (default): one combined product+implementation plan.
- Complex: two-stage plan (product doc, then implementation plan).

Instruction precedence:
- If this file conflicts with `AGENTS.core.md` or the consumer repo's `AGENTS.md`, follow the higher-precedence policy and update this playbook in the same change.

Execution mode:
- Default: sequential implementation in one task branch/worktree.
- Parallel implementation is opt-in and requires explicit user approval before creating additional branches/worktrees.
- You may recommend parallelization when workstreams are independent and materially reduce risk or elapsed time.
- If parallel is approved, include stream ownership boundaries, branch/worktree mapping, integration order, and integration verification.

Plan storage:
- Simple: in-thread mini checklist + timestamped progress updates.
- Normal/Complex: active plan file at `plans/<yyyy-mm-dd>-<slug>.md` plus in-thread progress updates.
- When done or canceled: move the plan to `plans/archive/<yyyy-mm-dd>-<slug>.md`.
- `plans/` files are committed by default so humans and agents share the same execution context.

Use templates:
- `playbooks/planning/combined-plan-template.md`
- `playbooks/planning/product-plan-template.md`
- `playbooks/planning/implementation-plan-template.md`
- Any repo-specific rollout or migration playbooks should remain local and be referenced from the consumer repo wrapper.

Required in every formal plan:
- executable checklist
- execution mode and approval status
- explicit test commands and pass criteria
- full-suite repo verification command unless a stricter superset is required
- docs impact checklist
- progress log with timestamps
