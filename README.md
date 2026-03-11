# workflow-core

Shared, repository-independent workflow guardrails and planning playbooks.

## Purpose
- Provide one canonical baseline for agent collaboration rules.
- Keep policy updates centralized and versioned.
- Allow repository-local adaptations without weakening core non-negotiables.

## Contents
- `AGENTS.core.md`: shared baseline guardrails.
- `AGENTS.local.template.md`: minimal local overlay template for consumer repos.
- `scripts/workflow/`: shared rendering and validation tooling for consumer repos.
- `scripts/workflow/review-guardrails`: optional prompt-based semantic review for shared-core versus local instruction conflicts and placement.
- `scripts/workflow/verify-integration`: shared integration suite for consumer repos, intended to be invoked through a thin local wrapper.
- `tests/test_workflow_tooling.sh`: regression checks for the shared tooling.
- `playbooks/git/`: shared worktree and rebase operational playbooks.
- `playbooks/planning/`: plan templates.
- `playbooks/planning/README.md`: planning standards and plan-storage rules.
- `playbooks/testing/behavior-test-design.md`: shared behavior-spec testing workflow.
- `playbooks/meta/local-adaptation-policy.md`: allowed local customization model.
- `playbooks/meta/agents-evolution.md`: shared policy-promotion workflow.
- `playbooks/meta/consumer-repo-integration.md`: concrete bootstrap and migration checklists for consumer repos.
- `playbooks/meta/shared-workflow-upgrade.md`: release and upgrade workflow.
- `docs/workflow-core-usage.md`: integration and rollout guidance.

## LLM Shortcut
For first-time adoption or migration in a consumer repository, tell the LLM:

`Do what's written in shared/workflow-core/playbooks/meta/consumer-repo-integration.md. Do not commit or push unless I explicitly ask.`

## Consumer Integration (Initial)
Use `playbooks/meta/consumer-repo-integration.md` for the exact bootstrap and migration checklists, wrapper script template, and minimal CI wiring.

1. Add this repo to consumer repos as a pinned dependency:
   - Git submodule (recommended), or
   - Git subtree.
2. Create a repo-local addendum (`AGENTS.local.md`) for local specifics.
   - Primarily set `WORKTREE_MAIN_ROOT`.
3. Compose the consumer's effective `AGENTS.md` using:
   - shared `AGENTS.core.md`
   - local `AGENTS.local.md`
   - thin local wrappers for `render-agents`, `validate-guardrails`, `review-guardrails`, and `verify-integration`
   - The generated file should contain a composed snapshot of both sources.
4. Run consumer verification and policy validation before merge.
   - `scripts/workflow/verify-integration`
   - Optional full repo verify around it: `scripts/verify`

## Versioning
- Use SemVer tags (`vMAJOR.MINOR.PATCH`).
- Document policy changes in `CHANGELOG.md`.
- Consumers should pin to explicit versions and upgrade via reviewed PRs.
- Follow `playbooks/meta/shared-workflow-upgrade.md` for release and rollout steps.
