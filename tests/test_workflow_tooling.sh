#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RENDER_SCRIPT="$CORE_ROOT/scripts/workflow/render-agents"
VALIDATE_SCRIPT="$CORE_ROOT/scripts/workflow/validate-guardrails"
REVIEW_SCRIPT="$CORE_ROOT/scripts/workflow/review-guardrails"
VERIFY_INTEGRATION_SCRIPT="$CORE_ROOT/scripts/workflow/verify-integration"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

assert_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -Fq -- "$pattern" "$file"; then
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

write_codex_stub() {
  local stub_path="$1"
  cat <<'EOF' >"$stub_path"
#!/usr/bin/env bash
set -euo pipefail

capture_dir="${WORKFLOW_GUARDRAILS_REVIEW_TEST_DIR:?}"
args_file="$capture_dir/review-args.txt"
prompt_file="$capture_dir/review-prompt.txt"
response_json="${WORKFLOW_GUARDRAILS_REVIEW_STUB_RESPONSE:?}"

printf '%s\n' "$@" >"$args_file"
cat >"$prompt_file"

output_file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output-last-message)
      output_file="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

printf '%s\n' "$response_json" >"$output_file"
EOF
  chmod +x "$stub_path"
}

write_slow_codex_stub() {
  local stub_path="$1"
  cat <<'EOF' >"$stub_path"
#!/usr/bin/env bash
set -euo pipefail

sleep "${WORKFLOW_GUARDRAILS_REVIEW_STUB_SLEEP_SECONDS:-2}"
EOF
  chmod +x "$stub_path"
}

new_repo() {
  local repo_root="$1"
  mkdir -p "$repo_root/shared/workflow-core/playbooks/meta" "$repo_root/shared/workflow-core/playbooks/git"
  cat <<'EOF' >"$repo_root/shared/workflow-core/AGENTS.core.md"
# AGENTS.core.md — Example Shared Core

## Core Rule
- Keep diffs minimal and atomic.
EOF
  cat <<'EOF' >"$repo_root/shared/workflow-core/playbooks/meta/local-adaptation-policy.md"
# Local Adaptation Policy
EOF
  cat <<'EOF' >"$repo_root/shared/workflow-core/playbooks/git/worktree-workflow.md"
# worktree workflow
EOF
  cat <<'EOF' >"$repo_root/shared/workflow-core/playbooks/git/worktree-operations.md"
# worktree operations
EOF
  cat <<'EOF' >"$repo_root/shared/workflow-core/playbooks/git/rebase-guide.md"
# rebase guide
EOF
}

install_local_wrappers() {
  local repo_root="$1"
  mkdir -p "$repo_root/scripts/workflow"
  cat <<'EOF' >"$repo_root/scripts/worktree"
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 || "$1" == "--help" || "$1" == "-h" ]]; then
  cat <<'HELP'
usage: worktree [-h] {create,rebase,push,cleanup,list} ...

Shared worktree command contract for this repository.

positional arguments:
  {create,rebase,push,cleanup,list}
    create
    rebase
    push
    cleanup
    list
HELP
  exit 0
fi

case "$1" in
  create|rebase|push|cleanup|list)
    exit 0
    ;;
  *)
    printf 'unknown worktree command: %s\n' "$1" >&2
    exit 1
    ;;
esac
EOF
  cat <<'EOF' >"$repo_root/scripts/workflow/render-agents"
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
exec "$REPO_ROOT/shared/workflow-core/scripts/workflow/render-agents" --repo-root "$REPO_ROOT" "$@"
EOF
  cat <<'EOF' >"$repo_root/scripts/workflow/validate-guardrails"
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
exec "$REPO_ROOT/shared/workflow-core/scripts/workflow/validate-guardrails" --repo-root "$REPO_ROOT" "$@"
EOF
  cat <<'EOF' >"$repo_root/scripts/workflow/review-guardrails"
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
exec "$REPO_ROOT/shared/workflow-core/scripts/workflow/review-guardrails" --repo-root "$REPO_ROOT" "$@"
EOF
  cat <<'EOF' >"$repo_root/scripts/workflow/verify-integration"
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
exec "$REPO_ROOT/shared/workflow-core/scripts/workflow/verify-integration" --repo-root "$REPO_ROOT" "$@"
EOF
  chmod +x \
    "$repo_root/scripts/worktree" \
    "$repo_root/scripts/workflow/render-agents" \
    "$repo_root/scripts/workflow/validate-guardrails" \
    "$repo_root/scripts/workflow/review-guardrails" \
    "$repo_root/scripts/workflow/verify-integration"
}

install_shared_tooling() {
  local repo_root="$1"
  mkdir -p \
    "$repo_root/shared/workflow-core/scripts/workflow" \
    "$repo_root/shared/workflow-core/tests" \
    "$repo_root/shared/workflow-core/playbooks/meta" \
    "$repo_root/shared/workflow-core/playbooks/planning" \
    "$repo_root/shared/workflow-core/playbooks/testing"
  cp "$CORE_ROOT/scripts/workflow/render-agents" "$repo_root/shared/workflow-core/scripts/workflow/render-agents"
  cp "$CORE_ROOT/scripts/workflow/validate-guardrails" "$repo_root/shared/workflow-core/scripts/workflow/validate-guardrails"
  cp "$CORE_ROOT/scripts/workflow/review-guardrails" "$repo_root/shared/workflow-core/scripts/workflow/review-guardrails"
  cp "$CORE_ROOT/scripts/workflow/verify-integration" "$repo_root/shared/workflow-core/scripts/workflow/verify-integration"
  cp "$CORE_ROOT/scripts/workflow/review-guardrails.schema.json" "$repo_root/shared/workflow-core/scripts/workflow/review-guardrails.schema.json"
  cp "$CORE_ROOT/playbooks/meta/local-adaptation-policy.md" "$repo_root/shared/workflow-core/playbooks/meta/local-adaptation-policy.md"
  cp "$CORE_ROOT/playbooks/meta/agents-evolution.md" "$repo_root/shared/workflow-core/playbooks/meta/agents-evolution.md"
  cp "$CORE_ROOT/playbooks/meta/shared-workflow-upgrade.md" "$repo_root/shared/workflow-core/playbooks/meta/shared-workflow-upgrade.md"
  cp "$CORE_ROOT/playbooks/meta/guardrail-review-rubric.md" "$repo_root/shared/workflow-core/playbooks/meta/guardrail-review-rubric.md"
  cp "$CORE_ROOT/playbooks/planning/README.md" "$repo_root/shared/workflow-core/playbooks/planning/README.md"
  cp "$CORE_ROOT/playbooks/planning/combined-plan-template.md" "$repo_root/shared/workflow-core/playbooks/planning/combined-plan-template.md"
  cp "$CORE_ROOT/playbooks/planning/implementation-plan-template.md" "$repo_root/shared/workflow-core/playbooks/planning/implementation-plan-template.md"
  cp "$CORE_ROOT/playbooks/planning/product-plan-template.md" "$repo_root/shared/workflow-core/playbooks/planning/product-plan-template.md"
  cp "$CORE_ROOT/playbooks/testing/behavior-test-design.md" "$repo_root/shared/workflow-core/playbooks/testing/behavior-test-design.md"
  cp "$CORE_ROOT/tests/test_workflow_tooling.sh" "$repo_root/shared/workflow-core/tests/test_workflow_tooling.sh"
  chmod +x \
    "$repo_root/shared/workflow-core/scripts/workflow/render-agents" \
    "$repo_root/shared/workflow-core/scripts/workflow/validate-guardrails" \
    "$repo_root/shared/workflow-core/scripts/workflow/review-guardrails" \
    "$repo_root/shared/workflow-core/scripts/workflow/verify-integration" \
    "$repo_root/shared/workflow-core/tests/test_workflow_tooling.sh"
}

printf '[workflow-core tests] render golden output...\n'
repo_render="$tmp_dir/repo-render"
new_repo "$repo_render"
install_shared_tooling "$repo_render"
install_local_wrappers "$repo_render"
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
# AGENTS.md — Example Repo Effective Policy

This file is generated from `shared/workflow-core/AGENTS.core.md` and `AGENTS.local.md`.
Do not edit manually; run `scripts/workflow/render-agents`.

## Source Files
- Shared core policy: `shared/workflow-core/AGENTS.core.md`
- Local overlay: `AGENTS.local.md`

## Shared Worktree Playbooks
  - `shared/workflow-core/playbooks/git/worktree-workflow.md`
  - `shared/workflow-core/playbooks/git/worktree-operations.md`
  - `shared/workflow-core/playbooks/git/rebase-guide.md`

## Shared Core Policy
### AGENTS.core.md — Example Shared Core

#### Core Rule
- Keep diffs minimal and atomic.

## Local Overlay
### AGENTS.local.md — Example Repo Local Overlay

#### Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/example/main`

#### Optional Additive Constraints
- Require `scripts/verify` before asking for a push.

<!-- END GENERATED: shared/workflow-core/scripts/workflow/render-agents -->
EOF
diff -u "$repo_render/expected-agents.md" "$repo_render/AGENTS.md"
"$RENDER_SCRIPT" --repo-root "$repo_render" --check

printf '[workflow-core tests] render check detects output drift...\n'
printf 'stale\n' >"$repo_render/AGENTS.md"
assert_fails "$tmp_dir/render-check.log" "$RENDER_SCRIPT" --repo-root "$repo_render" --check
assert_contains "$tmp_dir/render-check.log" 'AGENTS.md is out of date'

printf '[workflow-core tests] render check detects shared-core drift...\n'
repo_core_drift="$tmp_dir/repo-core-drift"
new_repo "$repo_core_drift"
cat <<'EOF' >"$repo_core_drift/AGENTS.local.md"
# AGENTS.local.md — Drift Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/drift/main`
EOF
"$RENDER_SCRIPT" --repo-root "$repo_core_drift"
cat <<'EOF' >"$repo_core_drift/shared/workflow-core/AGENTS.core.md"
# AGENTS.core.md — Example Shared Core

## Core Rule
- Updated shared rule text.
EOF
assert_fails "$tmp_dir/render-core-drift.log" "$RENDER_SCRIPT" --repo-root "$repo_core_drift" --check
assert_contains "$tmp_dir/render-core-drift.log" 'AGENTS.md is out of date'
"$RENDER_SCRIPT" --repo-root "$repo_core_drift" >/dev/null
assert_contains "$repo_core_drift/AGENTS.md" 'Updated shared rule text.'

printf '[workflow-core tests] render fails when required shared files are missing...\n'
repo_missing="$tmp_dir/repo-missing"
new_repo "$repo_missing"
cat <<'EOF' >"$repo_missing/AGENTS.local.md"
# AGENTS.local.md — Missing Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/missing/main`
EOF
rm "$repo_missing/shared/workflow-core/playbooks/git/rebase-guide.md"
assert_fails "$tmp_dir/render-missing.log" "$RENDER_SCRIPT" --repo-root "$repo_missing"
assert_contains "$tmp_dir/render-missing.log" 'Required shared rebase guide file not found'

printf '[workflow-core tests] validator accepts config-focused overlay...\n'
repo_valid="$tmp_dir/repo-valid"
new_repo "$repo_valid"
install_shared_tooling "$repo_valid"
install_local_wrappers "$repo_valid"
cat <<'EOF' >"$repo_valid/AGENTS.local.md"
# AGENTS.local.md — Valid Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/valid/main`

## Optional Additive Constraints
- Require `scripts/verify` before asking for a push.
- Do not add repository-local rules that weaken shared policy.
EOF
"$VALIDATE_SCRIPT" --repo-root "$repo_valid"

printf '[workflow-core tests] validator allows local tooling notes...\n'
repo_tooling="$tmp_dir/repo-tooling"
new_repo "$repo_tooling"
install_shared_tooling "$repo_tooling"
install_local_wrappers "$repo_tooling"
cat <<'EOF' >"$repo_tooling/AGENTS.local.md"
# AGENTS.local.md — Tooling Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/tooling/main`

## Local Tooling
- Python tasks can use `uv run` in this repository.
EOF
"$VALIDATE_SCRIPT" --repo-root "$repo_tooling"

printf '[workflow-core tests] validator rejects permissive overrides...\n'
repo_invalid="$tmp_dir/repo-invalid"
new_repo "$repo_invalid"
install_shared_tooling "$repo_invalid"
install_local_wrappers "$repo_invalid"
cat <<'EOF' >"$repo_invalid/AGENTS.local.md"
# AGENTS.local.md — Invalid Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/invalid/main`

## Optional Additive Constraints
- Agents may skip verification before push.
EOF
assert_fails "$tmp_dir/validate-invalid.log" "$VALIDATE_SCRIPT" --repo-root "$repo_invalid"
assert_contains "$tmp_dir/validate-invalid.log" 'permissively weaken shared policy'

printf '[workflow-core tests] validator rejects dangerous force-push guidance...\n'
repo_force="$tmp_dir/repo-force"
new_repo "$repo_force"
install_shared_tooling "$repo_force"
install_local_wrappers "$repo_force"
cat <<'EOF' >"$repo_force/AGENTS.local.md"
# AGENTS.local.md — Force Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/force/main`

## Local Tooling
- Use `git push --force-with-lease` when branch history gets messy.
EOF
assert_fails "$tmp_dir/validate-force.log" "$VALIDATE_SCRIPT" --repo-root "$repo_force"
assert_contains "$tmp_dir/validate-force.log" 'Dangerous command or workflow text'

printf '[workflow-core tests] validator enforces waiver metadata...\n'
repo_waiver="$tmp_dir/repo-waiver"
new_repo "$repo_waiver"
install_shared_tooling "$repo_waiver"
install_local_wrappers "$repo_waiver"
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

printf '[workflow-core tests] prompt review renders rubric-guided pass output...\n'
repo_review="$tmp_dir/repo-review"
new_repo "$repo_review"
install_shared_tooling "$repo_review"
install_local_wrappers "$repo_review"
cat <<'EOF' >"$repo_review/AGENTS.md"
# Generated AGENTS
EOF
cat <<'EOF' >"$repo_review/AGENTS.local.md"
# AGENTS.local.md — Review Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/review/main`

## Local Tooling
- Python tasks can use `uv run` in this repository.
EOF
cp "$CORE_ROOT/playbooks/meta/guardrail-review-rubric.md" "$repo_review/shared/workflow-core/playbooks/meta/guardrail-review-rubric.md"
cp "$CORE_ROOT/playbooks/meta/agents-evolution.md" "$repo_review/shared/workflow-core/playbooks/meta/agents-evolution.md"
cp "$CORE_ROOT/playbooks/meta/shared-workflow-upgrade.md" "$repo_review/shared/workflow-core/playbooks/meta/shared-workflow-upgrade.md"
mkdir -p "$repo_review/shared/workflow-core/playbooks/planning" "$repo_review/shared/workflow-core/playbooks/testing"
cp "$CORE_ROOT/playbooks/planning/README.md" "$repo_review/shared/workflow-core/playbooks/planning/README.md"
cp "$CORE_ROOT/playbooks/planning/combined-plan-template.md" "$repo_review/shared/workflow-core/playbooks/planning/combined-plan-template.md"
cp "$CORE_ROOT/playbooks/planning/implementation-plan-template.md" "$repo_review/shared/workflow-core/playbooks/planning/implementation-plan-template.md"
cp "$CORE_ROOT/playbooks/planning/product-plan-template.md" "$repo_review/shared/workflow-core/playbooks/planning/product-plan-template.md"
cp "$CORE_ROOT/playbooks/testing/behavior-test-design.md" "$repo_review/shared/workflow-core/playbooks/testing/behavior-test-design.md"
mkdir -p "$repo_review/playbooks/meta" "$repo_review/playbooks/planning" "$repo_review/playbooks/testing"
cat <<'EOF' >"$repo_review/playbooks/README.md"
# Playbooks
EOF
cat <<'EOF' >"$repo_review/playbooks/meta/agents-evolution.md"
# Local wrapper
EOF
cat <<'EOF' >"$repo_review/playbooks/meta/agents-candidates.md"
# Local candidates
EOF
cat <<'EOF' >"$repo_review/playbooks/planning/README.md"
# Local planning wrapper
EOF
cat <<'EOF' >"$repo_review/playbooks/testing/behavior-test-design.md"
# Local testing wrapper
EOF
write_codex_stub "$tmp_dir/codex-stub"
export WORKFLOW_GUARDRAILS_REVIEW_TEST_DIR="$tmp_dir"
export WORKFLOW_GUARDRAILS_REVIEW_STUB_RESPONSE='{"status":"pass","summary":"No conflicts found.","conflicts":[],"placement_findings":[],"resolved_or_ok":["Local tooling note stays local.","Shared-core policy remains the source of truth."]}'
WORKFLOW_GUARDRAILS_REVIEW_CODEX_BIN="$tmp_dir/codex-stub" "$REVIEW_SCRIPT" --repo-root "$repo_review" >"$tmp_dir/review-pass.log"
assert_contains "$tmp_dir/review-pass.log" '[review-guardrails] Status: pass'
assert_contains "$tmp_dir/review-pass.log" 'Local tooling note stays local.'
assert_contains "$tmp_dir/review-prompt.txt" 'Does any local instruction weaken, contradict, or redefine shared-core policy?'
assert_contains "$tmp_dir/review-prompt.txt" 'BEGIN FILE: AGENTS.local.md'
assert_contains "$tmp_dir/review-args.txt" '--output-schema'

printf '[workflow-core tests] prompt review can fail on warn when requested...\n'
export WORKFLOW_GUARDRAILS_REVIEW_STUB_RESPONSE='{"status":"warn","summary":"One placement cleanup is recommended.","conflicts":[],"placement_findings":[{"severity":"warn","instruction_summary":"Shared planning rule still appears locally.","current_location":"playbooks/planning/README.md","suggested_location":"shared-core","reason":"The rule is reusable and not repo-specific.","files":["playbooks/planning/README.md"],"resolution":"Keep only a thin local wrapper."}],"resolved_or_ok":[]}'
assert_fails "$tmp_dir/review-warn.log" env WORKFLOW_GUARDRAILS_REVIEW_CODEX_BIN="$tmp_dir/codex-stub" "$REVIEW_SCRIPT" --repo-root "$repo_review" --fail-on warn
assert_contains "$tmp_dir/review-warn.log" 'Status: warn'

printf '[workflow-core tests] prompt review fails on blocking conflict...\n'
export WORKFLOW_GUARDRAILS_REVIEW_STUB_RESPONSE='{"status":"fail","summary":"Local guidance conflicts with shared-core.","conflicts":[{"severity":"fail","title":"Force-push guidance conflicts with shared non-negotiables.","details":"A local note recommends git push --force-with-lease.","files":["AGENTS.local.md"],"resolution":"Remove the force-push guidance or move it into an explicit waiver with approval metadata."}],"placement_findings":[],"resolved_or_ok":[]}'
assert_fails "$tmp_dir/review-fail.log" env WORKFLOW_GUARDRAILS_REVIEW_CODEX_BIN="$tmp_dir/codex-stub" "$REVIEW_SCRIPT" --repo-root "$repo_review"
assert_contains "$tmp_dir/review-fail.log" 'Force-push guidance conflicts with shared non-negotiables.'

printf '[workflow-core tests] prompt review times out cleanly...\n'
write_slow_codex_stub "$tmp_dir/codex-slow-stub"
assert_fails "$tmp_dir/review-timeout.log" env WORKFLOW_GUARDRAILS_REVIEW_CODEX_BIN="$tmp_dir/codex-slow-stub" "$REVIEW_SCRIPT" --repo-root "$repo_review" --timeout-seconds 1
assert_contains "$tmp_dir/review-timeout.log" 'timed out after 1 seconds'

printf '[workflow-core tests] shared verify-integration runs consumer integration checks...\n'
repo_verify="$tmp_dir/repo-verify"
new_repo "$repo_verify"
install_shared_tooling "$repo_verify"
install_local_wrappers "$repo_verify"
cat <<'EOF' >"$repo_verify/AGENTS.local.md"
# AGENTS.local.md — Verify Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/verify/main`
EOF
cat <<'EOF' >"$repo_verify/AGENTS.md"
stale
EOF
"$repo_verify/shared/workflow-core/scripts/workflow/render-agents" --repo-root "$repo_verify" >/dev/null
WORKFLOW_GUARDRAILS_SKIP_CORE_TESTS=1 \
  "$VERIFY_INTEGRATION_SCRIPT" --repo-root "$repo_verify" --shared-root "$repo_verify/shared/workflow-core" >/dev/null

printf '[workflow-core tests] shared verify-integration requires local scripts/worktree...\n'
repo_verify_missing_worktree="$tmp_dir/repo-verify-missing-worktree"
new_repo "$repo_verify_missing_worktree"
install_shared_tooling "$repo_verify_missing_worktree"
install_local_wrappers "$repo_verify_missing_worktree"
cat <<'EOF' >"$repo_verify_missing_worktree/AGENTS.local.md"
# AGENTS.local.md — Verify Missing Worktree Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/verify-missing/main`
EOF
rm "$repo_verify_missing_worktree/scripts/worktree"
assert_fails "$tmp_dir/verify-missing-worktree.log" \
  env WORKFLOW_GUARDRAILS_SKIP_CORE_TESTS=1 \
  "$VERIFY_INTEGRATION_SCRIPT" --repo-root "$repo_verify_missing_worktree" --shared-root "$repo_verify_missing_worktree/shared/workflow-core"
assert_contains "$tmp_dir/verify-missing-worktree.log" 'Expected local worktree command not found'

printf '[workflow-core tests] shared verify-integration checks worktree help contract...\n'
repo_verify_bad_worktree="$tmp_dir/repo-verify-bad-worktree"
new_repo "$repo_verify_bad_worktree"
install_shared_tooling "$repo_verify_bad_worktree"
install_local_wrappers "$repo_verify_bad_worktree"
cat <<'EOF' >"$repo_verify_bad_worktree/AGENTS.local.md"
# AGENTS.local.md — Verify Bad Worktree Repo Local Overlay

## Local Config
- `WORKTREE_MAIN_ROOT`: `/tmp/verify-bad/main`
EOF
cat <<'EOF' >"$repo_verify_bad_worktree/scripts/worktree"
#!/usr/bin/env bash
set -euo pipefail
if [[ $# -eq 0 || "$1" == "--help" || "$1" == "-h" ]]; then
  printf 'usage: worktree {create,rebase,push,list}\n'
  exit 0
fi
if [[ "$1" == "list" ]]; then
  exit 0
fi
exit 0
EOF
chmod +x "$repo_verify_bad_worktree/scripts/worktree"
assert_fails "$tmp_dir/verify-bad-worktree.log" \
  env WORKFLOW_GUARDRAILS_SKIP_CORE_TESTS=1 \
  "$VERIFY_INTEGRATION_SCRIPT" --repo-root "$repo_verify_bad_worktree" --shared-root "$repo_verify_bad_worktree/shared/workflow-core"
assert_contains "$tmp_dir/verify-bad-worktree.log" 'does not advertise required subcommand: cleanup'

printf '[workflow-core tests] OK\n'
