---
summary: Behavior-spec-first testing workflow for designing tight, deterministic tests, including elaborate UI changes.
type: playbook
read_when:
  - Designing tests for behavior changes.
  - Implementing elaborate UI interactions with multiple states.
  - Tightening regression safety after bugs or UX regressions.
code_paths:
  - AGENTS.core.md
  - playbooks/testing/behavior-test-design.md
---

# Behavior Test Design Playbook

## Objective
Define expected behavior before coding, then encode it with tight tests that fail for the wrong behavior and pass for the right behavior.

## Step 1: Write Behavior Contract First
Before implementation, write a behavior contract with concrete scenarios.

Use this table format:

| Scenario ID | Context/State | User/System Action | Expected Outcome | Must Not Happen |
| --- | --- | --- | --- | --- |
| S1 | ... | ... | ... | ... |

Rules:
- Use observable outcomes (UI text/state, persisted value, emitted event, API response).
- Include at least one failure/negative scenario.
- For bug fixes, include the exact previously broken scenario.

## Step 2: Map Scenarios to Tests
Create a scenario-to-test mapping before coding.

| Scenario ID | Test Level | Test Location | Key Assertions |
| --- | --- | --- | --- |
| S1 | unit/integration/e2e | path/to/test | concrete assertions |

Selection guidance:
- Unit: pure logic and state transforms.
- Integration: module boundaries and side effects.
- E2E: user-visible flows and cross-boundary correctness.

## Step 3: UI Changes Require a State/Interaction Matrix
For elaborate UI work, define a matrix with key states and interactions.

Required state coverage:
- baseline/idle
- loading/pending
- success
- error/failure
- conflict/dirty/retry state (when relevant)

Required interaction coverage:
- primary pointer flow
- keyboard path (where supported)
- focus/disabled/guard behavior
- cancellation/retry behavior for async actions

## Step 4: Tight Test Rules
Tests must be deterministic and specific.

Required qualities:
- Assert exact behavior, not broad "renders" checks.
- Assert both positive and negative outcomes where risk is high.
- Avoid timing flake (`sleep`/arbitrary waits); wait on explicit signals.
- Prefer stable selectors (role/label/test-id by contract).
- Avoid snapshot-only verification for behavior changes.

For stateful features, assert both:
- visible UI result
- underlying state/side effect (store, API call, persisted data, audit/event)

## Step 5: Verify Test Signal Quality
Before final verification:
- Confirm new/changed tests fail against incorrect behavior.
- Confirm they pass with the correct implementation.
- Document executed commands and pass criteria in plan/progress log.

## Deliverables Per Behavior Change
- Behavior contract table
- Scenario-to-test mapping table
- New/updated tests for primary, edge, and failure paths
- Test run record (what ran, what skipped, residual risk)

## Consumer-Repo Supplements
- Keep repository-specific command catalogs in local docs such as `docs/quality/testing.md`.
- If a repo needs extra local testing playbooks, add them locally and reference this shared baseline.
- Push verification should use the consumer repository's configured verify command. In repos with split modes, a full-suite command such as `scripts/verify --full` should remain manual unless repo-local policy explicitly makes it the push gate.
- `scripts/workflow/verify-integration` only checks workflow-core integration and guardrails. Include it in repo verification, but do not treat it as product/build/test coverage.

## Dev-Server Policy Note
In AGENTS-governed workflows, assume dev servers are already running; only start/stop local dev servers when explicitly requested.
