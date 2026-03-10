#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RENDER_SCRIPT="$CORE_ROOT/scripts/workflow/render-agents"
VALIDATE_SCRIPT="$CORE_ROOT/scripts/workflow/validate-guardrails"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

assert_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -Fq "$pattern" "$file"; then
    printf 'Expected %s to contain: %s\n' "$file" "$pattern" >&2
    exit 1
  fi
}

assert_fails() {
  local log_file="$1"
  shift
  if "$@" >"$log_file" 2>&1; then
    printf 'Expected command to fail: %s\n' "$*" >&2
    cat "$log_file" >&2
    exit 1
  fi
}

new_repo() {
  local repo_root="$1"
  mkdir -p "$repo_root/shared/workflow-core/playbooks/meta"
  cat <<'EOF' >"$repo_root/shared/workflow-core/AGENTS.core.md"
# AGENTS.core.md
EOF
  cat <<'EOF' >"$repo_root/shared/workflow-core/playbooks/meta/local-adaptation-policy.md"
# Local Adaptation Policy
EOF
}

printf '[workflow-core tests] render golden output...\n'
repo_render="$tmp_dir/repo-render"
new_repo "$repo_render"
cat <<'EOF' >"$repo_render/AGENTS.local.md"
# AGENTS.local.md — Example Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/example/main`

## Optional Additive Constraints
- Require `scripts/verify` before asking for a push.
EOF
"$RENDER_SCRIPT" --repo-root "$repo_render"
cat <<'EOF' >"$repo_render/expected-agents.md"
<!-- BEGIN GENERATED: shared/workflow-core/scripts/workflow/render-agents -->
# AGENTS.md — Example Repo Policy Entrypoint

This file is generated from `shared/workflow-core/AGENTS.core.md` and `AGENTS.local.md`.
Do not edit manually; run `scripts/workflow/render-agents`.

## Policy Sources
- Shared core policy: `shared/workflow-core/AGENTS.core.md`
- Shared worktree playbooks:
  - `shared/workflow-core/playbooks/git/worktree-workflow.md`
  - `shared/workflow-core/playbooks/git/worktree-operations.md`
  - `shared/workflow-core/playbooks/git/rebase-guide.md`
- Local overlay: `AGENTS.local.md`

## Instruction Precedence
- explicit in-thread user instruction
- `AGENTS.local.md`
- `shared/workflow-core/AGENTS.core.md`
- playbooks/docs (`shared/workflow-core/playbooks/**` first, then local `playbooks/**`)

## Local Overlay Contract
- Keep `AGENTS.local.md` configuration-focused.
- Local rules may be additive/stricter only.
- Local rules may not weaken shared core non-negotiables.
- Worktree workflow is shared and must not be redefined locally.

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/example/main`

## Optional Additive Constraints
- Require `scripts/verify` before asking for a push.

<!-- END GENERATED: shared/workflow-core/scripts/workflow/render-agents -->
EOF
diff -u "$repo_render/expected-agents.md" "$repo_render/AGENTS.md"
"$RENDER_SCRIPT" --repo-root "$repo_render" --check

printf '[workflow-core tests] render check detects drift...\n'
printf 'stale\n' >"$repo_render/AGENTS.md"
assert_fails "$tmp_dir/render-check.log" "$RENDER_SCRIPT" --repo-root "$repo_render" --check
assert_contains "$tmp_dir/render-check.log" 'AGENTS.md is out of date'

printf '[workflow-core tests] validator accepts config-focused overlay...\n'
repo_valid="$tmp_dir/repo-valid"
new_repo "$repo_valid"
cat <<'EOF' >"$repo_valid/AGENTS.local.md"
# AGENTS.local.md — Valid Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/valid/main`

## Optional Additive Constraints
- Require `scripts/verify` before asking for a push.
- Do not add repository-local rules that weaken shared policy.
EOF
"$VALIDATE_SCRIPT" --repo-root "$repo_valid"

printf '[workflow-core tests] validator rejects permissive overrides...\n'
repo_invalid="$tmp_dir/repo-invalid"
new_repo "$repo_invalid"
cat <<'EOF' >"$repo_invalid/AGENTS.local.md"
# AGENTS.local.md — Invalid Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/invalid/main`

## Optional Additive Constraints
- Agents may skip verification before push.
EOF
assert_fails "$tmp_dir/validate-invalid.log" "$VALIDATE_SCRIPT" --repo-root "$repo_invalid"
assert_contains "$tmp_dir/validate-invalid.log" 'additive/stricter'

printf '[workflow-core tests] validator enforces waiver metadata...\n'
repo_waiver="$tmp_dir/repo-waiver"
new_repo "$repo_waiver"
cat <<'EOF' >"$repo_waiver/AGENTS.local.md"
# AGENTS.local.md — Waiver Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/waiver/main`

## Waivers
### temporary-exception
- `rule`: `Never do the thing`
- `scope`: `Only this repo`
EOF
assert_fails "$tmp_dir/validate-waiver.log" "$VALIDATE_SCRIPT" --repo-root "$repo_waiver"
assert_contains "$tmp_dir/validate-waiver.log" 'missing required fields'

printf '[workflow-core tests] OK\n'
