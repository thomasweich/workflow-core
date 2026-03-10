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
- `tests/test_workflow_tooling.sh`: regression checks for the shared tooling.
- `playbooks/git/`: shared worktree and rebase operational playbooks.
- `playbooks/planning/`: plan templates.
- `playbooks/planning/README.md`: planning standards and plan-storage rules.
- `playbooks/testing/behavior-test-design.md`: shared behavior-spec testing workflow.
- `playbooks/meta/local-adaptation-policy.md`: allowed local customization model.
- `playbooks/meta/agents-evolution.md`: shared policy-promotion workflow.
- `playbooks/meta/shared-workflow-upgrade.md`: release and upgrade workflow.
- `docs/workflow-core-usage.md`: integration and rollout guidance.

## Consumer Integration (Initial)
1. Add this repo to consumer repos as a pinned dependency:
   - Git submodule (recommended), or
   - Git subtree.
2. Create a repo-local addendum (`AGENTS.local.md`) for local specifics.
   - Primarily set `WORKTREE_MAIN_ROOT`.
3. Compose the consumer's effective `AGENTS.md` using:
   - shared `AGENTS.core.md`
   - local `AGENTS.local.md`
   - `scripts/workflow/render-agents`
4. Run consumer verification and policy validation before merge.
   - `scripts/workflow/render-agents --check`
   - `scripts/workflow/validate-guardrails`

## Versioning
- Use SemVer tags (`vMAJOR.MINOR.PATCH`).
- Document policy changes in `CHANGELOG.md`.
- Consumers should pin to explicit versions and upgrade via reviewed PRs.
- Follow `playbooks/meta/shared-workflow-upgrade.md` for release and rollout steps.
