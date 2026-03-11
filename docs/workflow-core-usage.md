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
  - planning/testing/documentation process guardrails
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
4. Create effective policy entrypoint:
   - `AGENTS.md` in consumer root, assembled from shared core + local overlay.
   - The generated file should contain a composed snapshot of the shared core policy plus the local overlay, not just pointers.
   - Add wrapper commands:
     - `scripts/workflow/render-agents`
     - `scripts/workflow/validate-guardrails`
     - `scripts/workflow/review-guardrails`
     - `scripts/workflow/verify-integration`
   - Commit the rendered `AGENTS.md`.
5. Add validation checks in CI:
   - core version pin is explicit
   - effective policy file is up to date
   - local overlay does not weaken core non-negotiables
   - Run the shared-owned integration suite:
     - `scripts/workflow/verify-integration`
   - Optional full repo verification around it:
     - `scripts/verify`

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

Keep local supplements only for repository-specific:
- command catalogs
- rollout or migration runbooks
- AGENTS candidate history or local governance logs

## Prompt-Based Semantic Review
When structural validation is not enough, run:
- `scripts/workflow/review-guardrails`

This review uses a fixed rubric to check:
- whether local instructions introduce a new conflict with shared-core
- whether any instruction needs resolution now
- whether each instruction belongs in shared-core, local files, or a thin local wrapper

Treat this as a semantic review layer on top of deterministic validation, not a replacement for `scripts/workflow/validate-guardrails`.

## Shared Integration Verifier
Consumer repos should keep the integration orchestration inside `workflow-core`.

Use:
- `scripts/workflow/verify-integration`

This wrapper should delegate to `shared/workflow-core/scripts/workflow/verify-integration`, which owns:
- shared script syntax checks
- shared workflow-core regression tests
- generated `AGENTS.md` drift detection
- local overlay validation
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
