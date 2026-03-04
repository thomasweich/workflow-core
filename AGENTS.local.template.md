# AGENTS.local.md — Local Overlay Template

Use this file in consumer repositories to provide local configuration values and additive constraints.

## Local Config
- `WORKTREE_MAIN_ROOT`: `<absolute-path-to-consumer-repo-main-worktree-root>`

## Optional Additive Constraints
- Add stricter (not weaker) repository-specific rules only when needed.
- Do not redefine shared worktree workflow or core non-negotiables.

## References
- `AGENTS.core.md`
- `playbooks/meta/local-adaptation-policy.md`
