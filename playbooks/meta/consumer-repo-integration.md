---
summary: Concrete bootstrap and migration checklists for integrating workflow-core into consumer repositories.
type: playbook
read_when:
  - Adding workflow-core to a brand-new repository.
  - Migrating an existing repository from repo-local workflow instructions.
  - Setting up thin consumer wrappers or guardrail CI.
code_paths:
  - AGENTS.local.template.md
  - docs/workflow-core-usage.md
  - docs/shared-plugins.md
  - scripts/workflow/render-agents
  - scripts/workflow/validate-guardrails
  - scripts/workflow/review-guardrails
  - scripts/workflow/verify-integration
  - playbooks/meta/local-adaptation-policy.md
  - playbooks/meta/shared-workflow-upgrade.md
---

# Consumer Repo Integration Playbook

## Goal
Provide one repeatable setup for both greenfield consumer repositories and migrations from repo-local workflow instructions.

## Standard Consumer Files
- `plans/`
- `plans/archive/`
- `shared/workflow-core/`
- `AGENTS.local.md`
- `AGENTS.md`
- `scripts/worktree`
- `scripts/workflow/render-agents`
- `scripts/workflow/validate-guardrails`
- `scripts/workflow/review-guardrails`
- `scripts/workflow/verify-integration`
- `scripts/verify`
- `.github/workflows/workflow-guardrails.yml`

If a consumer repo exposes shared Codex plugins, also expect:
- `.agents/plugins/marketplace.json`

## Wrapper Script Template
Use the same thin-wrapper pattern for all workflow-core consumer commands:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

exec "$REPO_ROOT/shared/workflow-core/scripts/workflow/<tool-name>" \
  --repo-root "$REPO_ROOT" \
  "$@"
```

Create wrappers for:
- `render-agents`
- `validate-guardrails`
- `review-guardrails`
- `verify-integration`

## Required `scripts/worktree` Contract
Consumer repositories must provide a local `scripts/worktree` command that satisfies the shared contract referenced by policy.

Minimum expectations:
- the file exists at `scripts/worktree`
- it is executable
- `scripts/worktree --help` succeeds without mutating repository state
- the `--help` output advertises:
  - `create`
  - `rebase`
  - `push`
  - `cleanup`
  - `list`
- `scripts/worktree list` is safe and non-mutating so shared verification can call it directly

Implementation options:
- native local implementation that follows the shared contract
- compatibility wrapper around an existing repo-local worktree tool, as long as the shared command names and behavior are preserved

Do not treat a consumer migration as complete while the generated policy references `scripts/worktree` commands that the repository does not actually provide.

## Minimal `scripts/verify`
If a consumer repo does not already have a repo-specific verify script, start with:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

printf '[verify] Shell syntax checks...\n'
bash -n scripts/verify
bash -n scripts/workflow/verify-integration

printf '[verify] workflow-core integration checks...\n'
scripts/workflow/verify-integration

printf '[verify] OK\n'
```

Append repo-specific checks after the workflow-core integration block.

`scripts/workflow/verify-integration` is the shared workflow-core integration check. It is intentionally not a shared all-repo verification script; consumer repositories own `scripts/verify` because product builds, runtime dependencies, language toolchains, and test suites are repo-specific.

If a repository splits verification into fast and full modes, make the mode boundary explicit:
- the fast/default command should be suitable for inner-loop feedback during implementation
- the full command must be the repository's pre-push gate and include workflow-core integration plus repo-specific build/test/doc checks
- local overlays and `scripts/worktree push --verify-cmd "<repo-verify-cmd>"` must reference the full command, for example `scripts/verify --full`

## Minimal CI Workflow
If the consumer repo does not already have guardrail CI, start with:

```yaml
name: Workflow Guardrails

on:
  pull_request:
  push:
    branches:
      - main

jobs:
  guardrails:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Run workflow-core integration checks
        run: scripts/workflow/verify-integration
```

If the repository needs language/runtime setup for its own `scripts/verify`, add that separately.

## Shared Plugin Consumption
If a consumer repo wants to expose a workflow-core-owned plugin, keep the ownership boundary explicit:
- plugin code and plugin-side docs live in `shared/workflow-core/plugins/<plugin-name>/`
- consumer repos keep local marketplace metadata in `.agents/plugins/marketplace.json`
- consumer repos may keep local docs for repo-specific output/storage policy

Use `docs/shared-plugins.md` for the concrete marketplace entry pattern and the current shared plugin examples.

## New Repository Bootstrap Checklist
1. Add `workflow-core` as a pinned dependency at `shared/workflow-core/`.
   - Recommended: `git submodule add <workflow-core-url> shared/workflow-core`
   - Pin to an explicit tag or commit before merge.
2. Create `AGENTS.local.md` from `AGENTS.local.template.md`.
3. Set `WORKTREE_MAIN_ROOT` to the absolute path for the repository's main worktree root.
4. Add or adapt `scripts/worktree` to the shared contract.
5. Keep `AGENTS.local.md` minimal:
   - repo-specific config
   - optional local tooling notes
   - optional stricter constraints
6. Add thin wrapper scripts for:
   - `scripts/workflow/render-agents`
   - `scripts/workflow/validate-guardrails`
   - `scripts/workflow/review-guardrails`
   - `scripts/workflow/verify-integration`
7. Make the wrappers and `scripts/worktree` executable.
8. Add `scripts/verify` or update the existing verify script to call `scripts/workflow/verify-integration`.
9. Generate the effective entrypoint:
   - `scripts/workflow/render-agents`
10. Optionally add thin local wrappers for shared playbooks you want to keep locally discoverable.
   - planning README/templates
   - testing behavior-test playbook
   - AGENTS-evolution playbook
11. Normalize formal plan storage to the shared contract.
   - active formal plans live in `plans/`
   - completed/canceled/superseded formal plans live in `plans/archive/`
   - do not leave completed formal plans in `plans/`
12. If the repo exposes shared plugins, point `.agents/plugins/marketplace.json` at `./shared/workflow-core/plugins/<plugin-name>`.
13. Add CI that runs `scripts/workflow/verify-integration`.
14. Run:
   - `scripts/workflow/verify-integration`
   - `scripts/verify`
   - optional `scripts/workflow/review-guardrails --fail-on never`
   - add `--timeout-seconds <n>` if the prompt review needs a longer budget in your environment
15. Review and commit:
   - pinned `workflow-core` revision
   - local overlay
   - generated `AGENTS.md`
   - `scripts/worktree`
   - wrapper scripts
   - CI wiring

## Existing Repository Migration Checklist
1. Inventory current workflow instructions and enforcement points.
   - `AGENTS.md`
   - `playbooks/**`
   - legacy worktree tooling (`scripts/worktree`, worktree helpers, shell aliases, docs)
   - local guardrail or validation scripts
   - CI jobs that already check policy or generated docs
2. Classify each instruction before moving it:
   - move to `workflow-core` if it is reusable across repositories
   - keep local if it is repo-specific configuration, paths, toolchain detail, rollout guidance, or history
   - keep as a thin wrapper if the content is shared but should remain locally discoverable
3. Add `workflow-core` as a pinned dependency at `shared/workflow-core/`.
4. Create `AGENTS.local.md` and move only local configuration and additive repo-specific notes into it.
5. Add or adapt local `scripts/worktree` to the shared contract before treating the migration as complete.
   - compatibility wrappers are acceptable if the shared command names and behavior are preserved
6. Replace the repo-local `AGENTS.md` with the generated entrypoint:
   - add wrapper scripts first
   - run `scripts/workflow/render-agents`
7. Replace copied shared playbooks with thin wrappers or direct references.
8. Update repo verification and CI to delegate workflow-core checks through:
   - `scripts/workflow/verify-integration`
9. Normalize formal plan storage to the shared contract.
   - active formal plans stay in `plans/`
   - completed/canceled/superseded formal plans move to `plans/archive/`
   - archive any stale completed plan still sitting in `plans/`
10. If the repo exposes shared plugins, repoint `.agents/plugins/marketplace.json` to `./shared/workflow-core/plugins/<plugin-name>` and remove any copied local plugin implementation.
11. Run semantic conflict and placement review:
   - `scripts/workflow/review-guardrails --fail-on never`
12. Review the migration diff for dropped instructions.
   - Every removed rule should now live in shared-core, `AGENTS.local.md`, a local supplement, or be intentionally deleted.
13. Run:
    - `scripts/workflow/verify-integration`
    - `scripts/verify`
    - optional `scripts/workflow/review-guardrails --fail-on never --timeout-seconds <n>`
14. Document the migration in the PR:
    - pinned `workflow-core` revision
    - which local files became thin wrappers
    - which instructions moved into shared-core
    - which local-only supplements remain
    - how `scripts/worktree` was implemented or adapted
    - any explicit waivers that were preserved

## Placement Rules During Migration
- Move to shared-core:
  - repo-independent worktree workflow
  - reusable planning/testing/meta process rules
  - shared validation logic and guardrail enforcement
- Keep local:
  - `WORKTREE_MAIN_ROOT`
  - repo-specific path layout
  - repo-specific tooling notes
  - rollout or migration runbooks
  - AGENTS candidate history
- Keep as thin wrapper:
  - shared playbooks that should stay easy to find from local paths
- Delete or collapse:
  - local copies that only restate shared-core policy
  - duplicated guardrail logic once shared-core owns the implementation

## Done Criteria
- `AGENTS.md` is generated and up to date.
- `AGENTS.local.md` passes structural validation.
- `scripts/worktree` satisfies the shared contract and passes integration verification.
- `plans/` contains only active formal plans; completed/canceled/superseded formal plans are archived under `plans/archive/`.
- CI runs `scripts/workflow/verify-integration`.
- Shared-core owns the integration logic; the consumer repo keeps only thin wrappers and repo-specific checks.
- No remaining local rule weakens or silently duplicates shared-core policy.
