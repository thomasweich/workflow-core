---
summary: Release and upgrade process for publishing workflow-core changes and consuming them safely in downstream repositories.
type: playbook
read_when:
  - Preparing a workflow-core release.
  - Upgrading a consumer repository to a newer workflow-core version.
code_paths:
  - CHANGELOG.md
  - docs/workflow-core-usage.md
  - scripts/workflow/render-agents
  - scripts/workflow/validate-guardrails
  - scripts/workflow/verify-integration
---

# Shared Workflow Upgrade Playbook

## Goal
Ship policy changes from `workflow-core` in a way that keeps consumer repositories pinned, reviewable, and verifiable.

## Release Process
1. Update shared policy/docs/tooling in `workflow-core`.
2. Update `CHANGELOG.md` with user-visible additions, changes, or removals.
3. Run workflow-core verification in a consumer repository that vendors the current checkout:
   - `shared/workflow-core/tests/test_workflow_tooling.sh`
   - consumer `scripts/workflow/verify-integration`
   - consumer `scripts/verify`
4. Tag the shared repository with a SemVer release (`vMAJOR.MINOR.PATCH`).
5. Announce upgrade notes:
   - breaking policy changes
   - required consumer file changes
   - any new validation or CI expectations

Use a major release when consumer repositories must change behavior or local overlay shape. Use a minor release for additive policy/tooling/docs. Use a patch release for backward-compatible fixes and clarifications.

## Consumer Upgrade Flow
1. Bump the pinned `shared/workflow-core` revision.
2. Review `CHANGELOG.md` and any changed playbooks/docs before editing local files.
   - If this is a first-time adoption or a repo-local migration, use `playbooks/meta/consumer-repo-integration.md` instead of this upgrade flow.
3. Regenerate the effective entrypoint:
   - `scripts/workflow/render-agents`
4. Validate local overlay compatibility:
   - `scripts/workflow/verify-integration`
5. Run consumer verification:
   - `scripts/verify`
6. Review the policy diff in the PR and call out:
   - shared-core version or commit bump
   - local overlay changes, if any
   - CI or tooling changes triggered by the upgrade

## Rollout Guidance
- Upgrade one pilot repository first when a change affects validation behavior or generated output format.
- After the pilot passes, roll the same shared revision into additional repositories sequentially unless the user explicitly approves a parallel rollout.
- If a consumer repo needs an exception, record it in that repo's `AGENTS.local.md` using the waiver metadata format defined in `playbooks/meta/local-adaptation-policy.md`.
