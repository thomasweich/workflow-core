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
- When the user explicitly requests a push, prefer landing verified changes on `origin/main` when that can be done safely without rewriting history; if not, push the task branch and report the blocker.
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

## 3) Collaboration Safety and Execution
- When the user approves an active plan or explicitly says to continue, execute the plan's sequential steps end-to-end without waiting for per-step confirmation.
- Pause only for blockers, ambiguous product decisions, destructive/history-risk actions, missing required access/configuration, or user-gated git actions.
- Use progress updates for visibility, not to request redundant permission.
- Commit completed verified atomic batches proactively on the active task branch unless the user asked to hold commits or batch them differently.
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
- `worktree.md` at the worktree root is the shared standard canonical worktree context/status file across consumer repositories.
- Keep `worktree.md` updated in the same task whenever worktree scope, active plans, or remaining high-level todos change.
- Keep open `worktree.md` todos slice-sized and truthfully current; broad initiatives belong in plans, and completed umbrella todos should be replaced with the next remaining slice.
- Follow the shared `worktree.md` standard in `docs/worktree-md-standard.md`; consumer repositories may add stricter additive sections, but must not silently redefine the meaning of `# Todos` or `# Active Plans`.
- Keep process docs concise and enforceable; move detailed rationale into playbooks.

## 6) Code Size Standard
- Keep non-generated source files near a target of 300 lines.
- Treat 450 lines as a hard limit for non-generated source files unless explicitly waived by the user.
- If touching a non-generated file already above 450 lines, include same-task extraction to reduce size or request an explicit waiver.
- Do not add new top-level functions/classes to non-generated files above 450 lines; extract to a new module instead.
- Keep functions near 40 lines and do not exceed 80 lines unless explicitly waived by the user.
- Include test source and CSS/SCSS source in these limits.
- Exclude generated files, migrations, vendored code, build output, lockfiles, and large test fixtures.

## 7) Testing and Verification
- Define expected behavior before implementing behavior changes.
- Add or update deterministic tests for primary, edge, and failure paths.
- Avoid snapshot-only assertions for behavior changes.
- Run targeted checks during iteration and repository full verification before push.
- Treat `<repo-verify-cmd>` as the consumer repository's full pre-push gate. A repo may also provide a faster default/inner-loop verify command, but push workflows and local overlays must name the full command.
- `shared/workflow-core/scripts/workflow/verify-integration` validates shared workflow guardrails; it is not a substitute for a consumer repository's full product/build/test verification.
- In final reporting, record what ran, what was skipped, and residual risk.

## 8) Planning Standard
- Use a plan for non-trivial work.
- Treat `plans/` as active-only plan storage.
- Archive completed, canceled, or superseded formal plans to `plans/archive/` in the same task before final reporting.
- Do not leave completed, canceled, or superseded formal plans in `plans/`.
- Every plan must include:
  - executable checklist (`[ ]` / `[x]`)
  - execution mode and approval status
  - explicit test commands and pass criteria
  - documentation impact checklist
  - timestamped progress log
- Use shared templates in `playbooks/planning/`.

## 9) Local Adaptation Contract
- Local overlays should be minimal and primarily provide local configuration values (for example `WORKTREE_MAIN_ROOT`).
- Local overlays may add repository-specific rules and stricter constraints only when needed.
- Local overlays may not weaken core non-negotiables.
- Local adaptation details and examples are defined in:
  - `playbooks/meta/local-adaptation-policy.md`
