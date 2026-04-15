---
summary: How consumer repositories should adopt and operate with workflow-core.
type: doc
read_when:
  - Integrating workflow-core into a repository.
  - Upgrading workflow-core version in consumer repositories.
code_paths: []
---

# workflow-core Usage

## Adoption Model
Consumer repositories should import `workflow-core` as a pinned dependency and combine shared core with local repository adaptations.

For concrete bootstrap and migration steps, use `playbooks/meta/consumer-repo-integration.md`.

## Shared vs Local Boundary
- Shared in `workflow-core`:
  - non-negotiables
  - worktree workflow and command contract
  - shared `worktree.md` standard for worktree-local context
  - approved-plan execution and atomic-commit defaults
  - planning/testing/documentation process guardrails
  - shared Codex plugins, skills, and reusable plugin-side documentation under `plugins/`
  - formal-plan lifecycle: active plans live in `plans/`, completed/canceled/superseded plans move to `plans/archive/` in the same task
  - AGENTS-evolution workflow for promoting policy changes
- Local in consumer repo:
  - configuration values only (primarily `WORKTREE_MAIN_ROOT`)
  - additive stricter rules if needed

## Recommended Integration Steps
1. Add shared core as a pinned dependency:
   - Submodule (recommended): `shared/workflow-core/`
   - Subtree (alternative if submodules are not allowed)
2. Add local overlay file:
   - `AGENTS.local.md` in consumer repository root
   - Keep this file minimal and configuration-focused.
3. Set required local config values:
   - `WORKTREE_MAIN_ROOT=<absolute-path-to-main-worktree-root>`
   - Derive task-worktree parent as `dirname(WORKTREE_MAIN_ROOT)`.
4. Adopt the shared `worktree.md` standard in consumer worktrees.
   - Use `worktree.md` at the worktree root as the canonical shared context file.
   - At minimum, support `# Todos` and `# Active Plans` per `docs/worktree-md-standard.md`.
   - If the repository already has another worktree-local context file, keep it supplemental rather than canonical.
5. Add or adapt `scripts/worktree` in the consumer repo so it satisfies the shared command contract.
   - `scripts/worktree --help` should succeed and advertise `create`, `rebase`, `push`, `cleanup`, and `list`.
   - `scripts/worktree list` should be safe and non-mutating.
   - Ensure worktree creation or onboarding bootstraps `worktree.md` when it is missing.
6. Create effective policy entrypoint:
   - `AGENTS.md` in consumer root, assembled from shared core + local overlay.
   - The generated file should contain a composed snapshot of the shared core policy plus the local overlay, not just pointers.
   - Add wrapper commands:
     - `scripts/workflow/render-agents`
     - `scripts/workflow/validate-guardrails`
     - `scripts/workflow/review-guardrails`
     - `scripts/workflow/verify-integration`
   - Commit the rendered `AGENTS.md`.
7. Add validation checks in CI:
   - core version pin is explicit
   - effective policy file is up to date
   - local overlay does not weaken core non-negotiables
   - local `scripts/worktree` satisfies the shared contract
   - repository verification should fail when the repo’s own stricter `worktree.md` checks fail
   - Run the shared-owned integration suite:
     - `scripts/workflow/verify-integration`
   - Optional full repo verification around it:
     - `scripts/verify`

## `worktree.md` Enforcement
The shared standard is enforced in layers:
- Shared policy: generated `AGENTS.md` propagates the `worktree.md` requirement into every consumer repo.
- Shared worktree workflow: `playbooks/git/worktree-workflow.md` requires `worktree.md` maintenance as part of normal task execution.
- Shared verification warning: `scripts/workflow/verify-integration` can warn on obviously broad open umbrella todos so stale branch-level work is noticed earlier.
- Consumer bootstrap: each repo should create or backfill `worktree.md` during worktree creation/onboarding.
- Consumer verification: repos should add any stricter schema/content checks they need to `scripts/verify`.
- Product/tooling adoption: local UIs and agents should read/write `worktree.md` instead of inventing parallel canonical context files.

## Local Overlay Guidance
- Keep local overlay scoped to repository specifics:
  - configuration values (especially `WORKTREE_MAIN_ROOT`)
  - local paths/layout derived from that root
  - local tooling notes (for example repository-native command hints)
  - stricter safety/verification constraints (if additive)
- Do not restate or weaken shared non-negotiables.
- Do not redefine shared worktree workflow rules locally.
- See `playbooks/meta/local-adaptation-policy.md`.

## Shared Playbooks Worth Wrapping Locally
Consumer repos should usually keep thin local wrappers for shared process docs so repository-specific supplements stay easy to find.

Recommended shared playbooks to wrap locally:
- `playbooks/planning/README.md`
- `playbooks/planning/*.md`
- `playbooks/testing/behavior-test-design.md`
- `playbooks/meta/agents-evolution.md`

Consumer repos should treat the shared planning storage contract as active guidance:
- `plans/` is for active formal plans only
- `plans/archive/` is for completed, canceled, or superseded formal plans

Keep local supplements only for repository-specific:
- command catalogs
- rollout or migration runbooks
- AGENTS candidate history or local governance logs

## Shared Plugins
Consumer repos may expose shared workflow-core plugins through their own local marketplace metadata.

Shared ownership:
- Plugin code lives under `shared/workflow-core/plugins/<plugin-name>/`.
- Consumer repos still own `.agents/plugins/marketplace.json`, because installation policy and local availability are consumer concerns.

Consumer marketplace pattern:

```json
{
  "name": "chatgpt-chat-export",
  "source": {
    "source": "local",
    "path": "./shared/workflow-core/plugins/chatgpt-chat-export"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

Use:
- `docs/shared-plugins.md`

to see the shared plugin consumption rules and the `chatgpt-chat-export` example.

## Prompt-Based Semantic Review
When structural validation is not enough, run:
- `scripts/workflow/review-guardrails`

This review uses a fixed rubric to check:
- whether local instructions introduce a new conflict with shared-core
- whether any instruction needs resolution now
- whether each instruction belongs in shared-core, local files, or a thin local wrapper

Treat this as a semantic review layer on top of deterministic validation, not a replacement for `scripts/workflow/validate-guardrails`.
The review is time-bounded by default; use `--timeout-seconds <n>` or `WORKFLOW_GUARDRAILS_REVIEW_TIMEOUT_SECONDS` to raise the limit when needed.

## Shared Integration Verifier
Consumer repos should keep the integration orchestration inside `workflow-core`.

Use:
- `scripts/workflow/verify-integration`

This wrapper should delegate to `shared/workflow-core/scripts/workflow/verify-integration`, which owns:
- shared script syntax checks
- shared workflow-core regression tests
- generated `AGENTS.md` drift detection
- local overlay validation
- local `scripts/worktree` contract validation
- optional prompt-based semantic review

## Upgrade Flow
1. Bump pinned `workflow-core` version.
2. Regenerate or refresh effective consumer policy files.
3. Review policy diff in PR.
4. Run repository verification.
5. Merge and propagate to additional repositories.
6. Follow `playbooks/meta/shared-workflow-upgrade.md` for release notes and rollout order.

## Change Management
- Treat shared-core updates as policy changes with explicit review.
- Record user-visible policy changes in consumer release notes when relevant.
