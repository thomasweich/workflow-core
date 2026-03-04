---
summary: Safe rebase and conflict-resolution checklist for rebasing task branches onto origin/main.
type: playbook
read_when:
  - User requests syncing with latest main via rebase.
  - Rebase stops on conflicts.
code_paths:
  - scripts/worktree
---

# Git Rebase Guide

## Rebase Workflow
1. Confirm branch scope before rebasing.
2. Ensure the target worktree is clean.
3. Fetch latest remote refs.
4. Rebase onto `origin/main`.
5. Resolve conflicts with `origin/main` as baseline.
6. Re-run verification.
7. Continue to push only after rebase and verification succeed.

## Commands
Use helper:

```bash
scripts/worktree rebase --branch <branch>
```

Fallback:

```bash
git fetch --prune origin
git rebase origin/main
```

## Conflict Policy
1. Treat `origin/main` behavior as baseline.
2. Re-apply branch intent on top of baseline.
3. Avoid silent behavior regressions from either side.
4. Document non-obvious conflict choices in commit message body.

## Conflict Loop
1. Inspect conflict markers and surrounding code.
2. Resolve one file at a time.
3. Run narrow verification for affected area.
4. Stage resolved files.
5. Continue rebase.

```bash
git status
git add <resolved-files>
git rebase --continue
```

Abort only when necessary:

```bash
git rebase --abort
```
