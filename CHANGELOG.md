# Changelog

All notable changes to `workflow-core` will be documented in this file.

The format is based on Keep a Changelog and this project follows SemVer.

## [Unreleased]
### Changed
- Approved formal plans now authorize end-to-end sequential execution by default, with progress updates for visibility rather than redundant per-step permission prompts.
- Shared-core now defaults to proactively committing completed verified atomic batches unless the user asked to hold commits or batch them differently.
- Consumer integration guidance now requires a concrete `scripts/worktree` contract decision instead of assuming the command exists implicitly.
- Shared `verify-integration` now validates the consumer `scripts/worktree` contract via `--help` and safe `list` execution.
- Planning docs now distinguish shared-required plan structure and storage from allowed consumer-local planning supplements more explicitly.
- Shared push guidance now prefers landing verified changes on `origin/main` when a push is explicitly requested and direct main update is safe; otherwise agents should push the task branch and report the blocker.
- `render-agents` now emits a composed `AGENTS.md` snapshot that includes shared-core policy content plus the local overlay, so shared-core changes produce generated-file drift.
- `render-agents` now fails fast when required shared playbook files are missing.
- `validate-guardrails` now allows repository-local tooling notes while rejecting dangerous force-push and permissive workflow-override guidance more precisely.
- Added optional `review-guardrails` prompt-based review with a shared rubric and structured output schema for shared-core versus local conflicts and placement review.
- Added `playbooks/meta/consumer-repo-integration.md` with concrete bootstrap and migration checklists, wrapper templates, and minimal CI wiring for consumer repos.
- Shared worktree playbooks now define a terminal-plus-Codex launch contract instead of the older iTerm2/`hapi codex --yolo` wording.
- `review-guardrails` now fails fast with a configurable timeout instead of hanging indefinitely when the nested Codex review stalls.

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
