---
summary: Shared operational guide for scripted git worktree lifecycle (create, rebase, push, cleanup, list).
type: playbook
read_when:
  - Starting a new task branch/worktree.
  - Rebasing, pushing, or cleaning up task branches.
code_paths:
  - scripts/worktree
  - AGENTS.md
  - AGENTS.local.md
---

# Git Worktree Workflow

## Shared Defaults
- Remote: `origin`
- Integration branch: `main`
- Base ref: `origin/main`
- Branch pattern: `agent/<task-slug>`
- Worktree path pattern: sibling of main worktree root (`<main-worktree-parent>/<branch-name>`)
- Launch behavior for `create`: attempt to open a terminal session and run `codex --dangerously-bypass-approvals-and-sandbox`

## Required Local Config Input
- `WORKTREE_MAIN_ROOT`: absolute path to the consumer repository's main worktree root.
- Derived path:
  - `<main-worktree-parent>` is `dirname(WORKTREE_MAIN_ROOT)`.
  - Task worktrees are created at `<main-worktree-parent>/<branch-name>`.

## Task-Slug Convention
- Use lowercase kebab-case, 2-5 words, action-oriented.
- Prefer `<area>-<change>-<intent>` when possible.
- Avoid ticket-only slugs (`abc-123`) unless intent is included (`abc-123-auth-timeout-fix`).
- Examples: `auth-token-refresh`, `billing-webhook-retry`, `ui-settings-empty-state`.
- Script behavior should normalize invalid characters to `-` and lowercase uppercase input.

## Primary Commands
1. Create task worktree:
   - `scripts/worktree create <task-slug>`
   - Add `--no-codex` to skip terminal/Codex auto-launch.
   - If `--no-codex` is used, immediately print the exact manual command:
     - `cd <worktree-path> && codex --dangerously-bypass-approvals-and-sandbox`
   - If auto-launch is unavailable, print the same manual command instead of failing.
2. Rebase task branch onto latest base:
   - `scripts/worktree rebase --branch <branch-name>`
3. Push task branch with verification:
   - `scripts/worktree push --branch <branch-name> --verify-cmd "<repo-verify-cmd>"`
4. Cleanup after merge:
   - `scripts/worktree cleanup <branch-name>`
5. Inspect current worktrees:
   - `scripts/worktree list`

## Parallel Execution Gate
- Default execution mode is sequential: use one task branch/worktree per request.
- If parallel implementation may help, propose workstream boundaries, contracts, and integration order first.
- Create additional branches/worktrees only after explicit user approval.

## Required Policy
1. Commits on the active task branch are always allowed.
2. Run rebase/merge/push/cleanup only when the user explicitly requested integration/push/cleanup.
3. Default to sequential execution with one task worktree/branch unless parallel implementation is explicitly approved.
4. Create additional task worktrees/branches only after explicit user approval.
5. When the user explicitly requests push, try to land verified changes on `origin/main` first unless they specifically asked for a branch push.
6. If direct main push is blocked, unsupported by the repo tooling, or unsafe, push `<remote>/<branch>` instead and report the blocker.
7. Require clean tracked changes for operations unless an explicit override flag is used.
8. Before push, ensure branch includes latest `origin/main`.
9. After merge, cleanup should remove worktree, local branch, and remote branch.
10. Treat unknown local edits as owned by another human/agent unless explicitly told otherwise.
11. Never revert or discard unrelated edits during worktree operations.
12. If shared files changed in parallel, apply minimal hunk-level changes and escalate when intent is unclear.
13. Documentation updates are part of implementation and should be done before final verification for push.
14. Before push, run the repository verify command and record what ran.
15. If `--no-codex` is used during `create`, immediately print the manual `cd <worktree-path> && codex --dangerously-bypass-approvals-and-sandbox` command.
16. If auto-launch is unavailable in the current environment, print the same manual command and continue.
17. `push` must explicitly target `<remote>/<branch>` and correct upstream tracking when local tracking is mismatched.

## Create Behavior
- `create` should be idempotent for branch-to-worktree mapping:
  - If the branch worktree already exists, reuse it.
  - If the branch exists locally but is not checked out in a worktree path, create the sibling-of-main-root worktree directly from that branch.
- `--reuse` is only needed when intentionally using a pre-existing target directory path.

## Rebase Conflicts
When rebase stops on conflicts, use `playbooks/git/rebase-guide.md`.

## Cleanup Rule
`cleanup` should only proceed when branch is merged into `origin/main`, unless force mode is explicitly requested.

For full option matrix and edge-case behavior, see `playbooks/git/worktree-operations.md`.
