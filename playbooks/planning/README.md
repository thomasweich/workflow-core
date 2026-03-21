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

Execution authority:
- User approval of a formal plan authorizes end-to-end execution of that plan's sequential steps by default.
- After approval, progress updates should inform the user about status and decisions, not ask for redundant per-step permission.
- Pause only for blockers, ambiguous product decisions, destructive/history-risk actions, missing required access/configuration, or user-gated git actions.
- Completed verified atomic batches should be committed proactively unless the user explicitly asked to hold commits or batch them differently.

Plan storage:
- Simple: in-thread mini checklist + timestamped progress updates.
- Normal/Complex: active plan file at `plans/<yyyy-mm-dd>-<slug>.md` plus in-thread progress updates.
- When done or canceled: move the plan to `plans/archive/<yyyy-mm-dd>-<slug>.md`.
- `plans/` files are committed by default so humans and agents share the same execution context.

Shared-required versus consumer-local planning details:
- Shared-required defaults:
  - planning depth model (`Simple` / `Normal` / `Complex`)
  - required formal-plan fields listed below
  - active formal plan storage under `plans/`
  - archived formal plan storage under `plans/archive/`
  - plan files committed by default
- Consumer-local additions are allowed for:
  - rollout or migration runbooks
  - stricter local checklist items or approval gates
  - local plan indexes, wrapper docs, or references to shared templates
- Consumer repos should not relocate active formal plans outside `plans/` or drop required plan fields while claiming default shared-core compliance.

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
