# Changelog

All notable changes to `workflow-core` will be documented in this file.

The format is based on Keep a Changelog and this project follows SemVer.

## [Unreleased]

## [0.2.0] - 2026-03-10
### Added
- Shared git/worktree playbooks:
  - `playbooks/git/worktree-workflow.md`
  - `playbooks/git/worktree-operations.md`
  - `playbooks/git/rebase-guide.md`
- `AGENTS.local.template.md` for configuration-focused local overlays.
- Shared tooling:
  - `scripts/workflow/render-agents`
  - `scripts/workflow/validate-guardrails`
  - `tests/test_workflow_tooling.sh`
- Shared playbooks:
  - `playbooks/planning/README.md`
  - `playbooks/testing/behavior-test-design.md`
  - `playbooks/meta/agents-evolution.md`
- `playbooks/meta/shared-workflow-upgrade.md` for release and consumer upgrade flow.

### Changed
- Clarified that worktree policy is shared and local overlays should primarily provide configuration values such as `WORKTREE_MAIN_ROOT`.
- Documented recommended local overlay sections and waiver metadata format.
- Clarified that consumer repos should keep only thin local wrappers for reusable shared playbooks plus repo-specific supplements.

## [0.1.0] - 2026-03-04
### Added
- Initial repository bootstrap.
- Shared baseline policy in `AGENTS.core.md`.
- Planning templates in `playbooks/planning/`.
- Local adaptation guardrails in `playbooks/meta/local-adaptation-policy.md`.
- Consumer integration guidance in `docs/workflow-core-usage.md`.
