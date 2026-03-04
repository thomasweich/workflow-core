# Changelog

All notable changes to `workflow-core` will be documented in this file.

The format is based on Keep a Changelog and this project follows SemVer.

## [Unreleased]
### Added
- Shared git/worktree playbooks:
  - `playbooks/git/worktree-workflow.md`
  - `playbooks/git/worktree-operations.md`
  - `playbooks/git/rebase-guide.md`
- `AGENTS.local.template.md` for configuration-focused local overlays.
- Core non-negotiable: do not ask users to push; wait for explicit user push initiation.

### Changed
- Clarified that worktree policy is shared and local overlays should primarily provide configuration values such as `WORKTREE_MAIN_ROOT`.
- Normalized worktree `create` launch guidance to use `codex --dangerously-bypass-approvals-and-sandbox` with terminal-app agnostic wording.
- Added explicit fallback requirement: if `create` auto-launch fails, print the exact manual `cd <worktree-path> && codex --dangerously-bypass-approvals-and-sandbox` command.

## [0.1.0] - 2026-03-04
### Added
- Initial repository bootstrap.
- Shared baseline policy in `AGENTS.core.md`.
- Planning templates in `playbooks/planning/`.
- Local adaptation guardrails in `playbooks/meta/local-adaptation-policy.md`.
- Consumer integration guidance in `docs/workflow-core-usage.md`.
