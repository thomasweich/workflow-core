---
summary: Shared command/options matrix for scripts/worktree operations.
type: playbook
read_when:
  - Needing command flags or edge-case behavior for worktree operations.
code_paths:
  - scripts/worktree
---

# scripts/worktree Operations

## Shared Path Model
- Local input: `WORKTREE_MAIN_ROOT` absolute path.
- Derived tasks root: `dirname(WORKTREE_MAIN_ROOT)`.
- Task worktree target: `<derived-tasks-root>/<branch-name>`.

## create
- Command: `scripts/worktree create <task-slug>`
- Purpose: create `agent/<slug>` branch from `origin/main` and worktree at sibling-of-main-root path.
- Policy gate: default to one task worktree/branch; create additional parallel worktrees only after explicit user approval.
- Behavior:
  - If branch worktree already exists, it is reused.
  - If branch exists locally, it is attached to sibling-of-main-root worktree path automatically.
  - By default, opens a new iTerm2 window and runs:
    - `hapi codex --yolo`
- Slug guidance: lowercase kebab-case, 2-5 words, action-oriented.
- Normalization: script lowercases input and converts invalid characters/spaces to `-`.
- Useful flags:
  - `--branch <name>` custom branch name
  - `--remote <name>` custom remote
  - `--base <branch>` custom base branch
  - `--reuse` allow pre-existing target path usage
  - `--no-fetch` skip fetch
  - `--allow-dirty` bypass clean-check
  - `--no-codex` skip iTerm2/Codex auto-launch
  - `--codex-cmd <cmd>` override Codex launch command
- If `--no-codex` is used, immediately print the exact manual command:
  - `cd <worktree-path> && codex --dangerously-bypass-approvals-and-sandbox`

## rebase
- Command: `scripts/worktree rebase --branch <branch-name>`
- Purpose: fetch and rebase branch onto `origin/main`.
- Useful flags:
  - `--remote <name>`
  - `--base <branch>`
  - `--no-fetch`
  - `--allow-main` (only with explicit user request)
  - `--allow-dirty`

## push
- Command: `scripts/worktree push --branch <branch-name> --verify-cmd "<repo-verify-cmd>"`
- Purpose: verify branch is up-to-date with base, run checks, then push to `<remote>/<branch>`.
- Upstream behavior: if tracking does not match `<remote>/<branch>`, `push` resets upstream to the matching remote branch during push.
- Useful flags:
  - `--verify-cmd <cmd>` (recommended: repository verify command)
  - `--no-verify`
  - `--allow-main` (only with explicit user request)
  - `--allow-dirty`

## cleanup
- Command: `scripts/worktree cleanup <branch-name>`
- Purpose: delete merged branch worktree, local branch, and remote branch.
- Useful flags:
  - `--keep-remote` keep remote branch
  - `--force` bypass merge/clean safety checks
  - `--remote <name>`
  - `--base <branch>`
  - `--no-fetch`

## list
- Command: `scripts/worktree list`
- Purpose: show active worktrees.
