# AGENTS.core.md — Shared Workflow Guardrails

This file defines repository-independent baseline rules for agent-driven engineering workflows.

## 0) Instruction Precedence
- For process instructions in consumer repositories, use this order:
  - explicit in-thread user instruction
  - repository-local overlay (for example `AGENTS.local.md`)
  - this shared core (`AGENTS.core.md`)
  - playbooks/templates/docs
- If lower-precedence docs conflict with higher-precedence policy, follow the higher-precedence policy and align docs in the same change.

## 1) Core Non-negotiables
- Never rewrite shared history (force-push, destructive resets, rebasing protected/default branches) unless the user explicitly requests it in-thread.
- Rebase/merge/push/cleanup are user-gated actions; do them only when explicitly requested in-thread.
- Keep diffs minimal and atomic; no unrelated cleanup edits.
- Stop and ask before any action that can lose data/history.
- Do not commit secrets/credentials or production `.env` files.
- Prefer highest-quality implementations that satisfy requirements; shortcuts require explicit user request and documented tradeoffs.

## 2) Branch and Worktree Discipline
- Use a task branch/worktree by default.
- Keep execution mode sequential by default (one branch/worktree per task) unless the user explicitly approves parallel implementation.
- Create additional branches/worktrees only after explicit user approval.
- Worktree policy and command contract are shared across consumer repositories:
  - `scripts/worktree create <task-slug>`
  - `scripts/worktree rebase --branch <branch>`
  - `scripts/worktree push --branch <branch> --verify-cmd "<repo-verify-cmd>"`
  - `scripts/worktree cleanup <branch>`
  - `scripts/worktree list`
- Required local configuration input for worktrees:
  - `WORKTREE_MAIN_ROOT`: absolute path to the repository's main worktree root
- Path derivation rule:
  - task worktrees live as siblings under `dirname(WORKTREE_MAIN_ROOT)`
  - task path pattern: `<dirname(WORKTREE_MAIN_ROOT)>/<branch-name>`
- Shared worktree details live in:
  - `playbooks/git/worktree-workflow.md`
  - `playbooks/git/worktree-operations.md`

## 3) Collaboration Safety
- Treat unknown local edits as owned by another human/agent.
- Do not revert or discard unrelated edits.
- If shared files are modified by others, apply minimal hunk-level edits around required lines.
- Stage only owned files/hunks and review staged diff before commit.

## 4) Runtime and Tooling
- Use repository-native toolchains unless the user explicitly requests alternatives.
- Document new flags/env vars/config behavior in the same change.
- Fail fast on missing required configuration with actionable error messages.

## 5) Documentation Standard
- Behavior/API/workflow/architecture changes require doc updates in the same task.
- Pure refactors/test-only/cosmetic-only changes can skip docs unless they alter operational behavior.
- Keep process docs concise and enforceable; move detailed rationale into playbooks.

## 6) Testing and Verification
- Define expected behavior before implementing behavior changes.
- Add or update deterministic tests for primary, edge, and failure paths.
- Avoid snapshot-only assertions for behavior changes.
- Run targeted checks during iteration and repository full verification before push.
- In final reporting, record what ran, what was skipped, and residual risk.

## 7) Planning Standard
- Use a plan for non-trivial work.
- Every plan must include:
  - executable checklist (`[ ]` / `[x]`)
  - execution mode and approval status
  - explicit test commands and pass criteria
  - documentation impact checklist
  - timestamped progress log
- Use shared templates in `playbooks/planning/`.

## 8) Local Adaptation Contract
- Local overlays should be minimal and primarily provide local configuration values (for example `WORKTREE_MAIN_ROOT`).
- Local overlays may add repository-specific rules and stricter constraints only when needed.
- Local overlays may not weaken core non-negotiables.
- Local adaptation details and examples are defined in:
  - `playbooks/meta/local-adaptation-policy.md`
