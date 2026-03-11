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
- `shared/workflow-core/`
- `AGENTS.local.md`
- `AGENTS.md`
- `scripts/workflow/render-agents`
- `scripts/workflow/validate-guardrails`
- `scripts/workflow/review-guardrails`
- `scripts/workflow/verify-integration`
- `scripts/verify`
- `.github/workflows/workflow-guardrails.yml`

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

## New Repository Bootstrap Checklist
1. Add `workflow-core` as a pinned dependency at `shared/workflow-core/`.
   - Recommended: `git submodule add <workflow-core-url> shared/workflow-core`
   - Pin to an explicit tag or commit before merge.
2. Create `AGENTS.local.md` from `AGENTS.local.template.md`.
3. Set `WORKTREE_MAIN_ROOT` to the absolute path for the repository's main worktree root.
4. Keep `AGENTS.local.md` minimal:
   - repo-specific config
   - optional local tooling notes
   - optional stricter constraints
5. Add thin wrapper scripts for:
   - `scripts/workflow/render-agents`
   - `scripts/workflow/validate-guardrails`
   - `scripts/workflow/review-guardrails`
   - `scripts/workflow/verify-integration`
6. Make the wrappers executable.
7. Add `scripts/verify` or update the existing verify script to call `scripts/workflow/verify-integration`.
8. Generate the effective entrypoint:
   - `scripts/workflow/render-agents`
9. Optionally add thin local wrappers for shared playbooks you want to keep locally discoverable.
   - planning README/templates
   - testing behavior-test playbook
   - AGENTS-evolution playbook
10. Add CI that runs `scripts/workflow/verify-integration`.
11. Run:
   - `scripts/workflow/verify-integration`
   - `scripts/verify`
   - optional `scripts/workflow/review-guardrails --fail-on never`
12. Review and commit:
   - pinned `workflow-core` revision
   - local overlay
   - generated `AGENTS.md`
   - wrapper scripts
   - CI wiring

## Existing Repository Migration Checklist
1. Inventory current workflow instructions and enforcement points.
   - `AGENTS.md`
   - `playbooks/**`
   - local guardrail or validation scripts
   - CI jobs that already check policy or generated docs
2. Classify each instruction before moving it:
   - move to `workflow-core` if it is reusable across repositories
   - keep local if it is repo-specific configuration, paths, toolchain detail, rollout guidance, or history
   - keep as a thin wrapper if the content is shared but should remain locally discoverable
3. Add `workflow-core` as a pinned dependency at `shared/workflow-core/`.
4. Create `AGENTS.local.md` and move only local configuration and additive repo-specific notes into it.
5. Replace the repo-local `AGENTS.md` with the generated entrypoint:
   - add wrapper scripts first
   - run `scripts/workflow/render-agents`
6. Replace copied shared playbooks with thin wrappers or direct references.
7. Update repo verification and CI to delegate workflow-core checks through:
   - `scripts/workflow/verify-integration`
8. Run semantic conflict and placement review:
   - `scripts/workflow/review-guardrails --fail-on never`
9. Review the migration diff for dropped instructions.
   - Every removed rule should now live in shared-core, `AGENTS.local.md`, a local supplement, or be intentionally deleted.
10. Run:
    - `scripts/workflow/verify-integration`
    - `scripts/verify`
11. Document the migration in the PR:
    - pinned `workflow-core` revision
    - which local files became thin wrappers
    - which instructions moved into shared-core
    - which local-only supplements remain
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
- CI runs `scripts/workflow/verify-integration`.
- Shared-core owns the integration logic; the consumer repo keeps only thin wrappers and repo-specific checks.
- No remaining local rule weakens or silently duplicates shared-core policy.
