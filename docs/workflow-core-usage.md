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

## Recommended Integration Steps
1. Add shared core as a pinned dependency:
   - Submodule (recommended): `shared/workflow-core/`
   - Subtree (alternative if submodules are not allowed)
2. Add local overlay file:
   - `AGENTS.local.md` in consumer repository root
3. Create effective policy entrypoint:
   - `AGENTS.md` in consumer root, assembled from shared core + local overlay.
4. Add validation checks in CI:
   - core version pin is explicit
   - effective policy file is up to date
   - local overlay does not weaken core non-negotiables

## Local Overlay Guidance
- Keep local overlay scoped to repository specifics:
  - tooling commands
  - paths/layout
  - stricter safety/verification constraints
- Do not restate or weaken shared non-negotiables.
- See `playbooks/meta/local-adaptation-policy.md`.

## Upgrade Flow
1. Bump pinned `workflow-core` version.
2. Regenerate or refresh effective consumer policy files.
3. Review policy diff in PR.
4. Run repository verification.
5. Merge and propagate to additional repositories.

## Change Management
- Treat shared-core updates as policy changes with explicit review.
- Record user-visible policy changes in consumer release notes when relevant.
