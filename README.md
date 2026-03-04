# workflow-core

Shared, repository-independent workflow guardrails and planning playbooks.

## Purpose
- Provide one canonical baseline for agent collaboration rules.
- Keep policy updates centralized and versioned.
- Allow repository-local adaptations without weakening core non-negotiables.

## Contents
- `AGENTS.core.md`: shared baseline guardrails.
- `playbooks/planning/`: plan templates.
- `playbooks/meta/local-adaptation-policy.md`: allowed local customization model.
- `docs/workflow-core-usage.md`: integration and rollout guidance.

## Consumer Integration (Initial)
1. Add this repo to consumer repos as a pinned dependency:
   - Git submodule (recommended), or
   - Git subtree.
2. Create a repo-local addendum (`AGENTS.local.md`) for local specifics.
3. Compose the consumer's effective `AGENTS.md` using:
   - shared `AGENTS.core.md`
   - local `AGENTS.local.md`
4. Run consumer verification and policy validation before merge.

## Versioning
- Use SemVer tags (`vMAJOR.MINOR.PATCH`).
- Document policy changes in `CHANGELOG.md`.
- Consumers should pin to explicit versions and upgrade via reviewed PRs.
