---
summary: Rules for repository-local adaptations layered on top of AGENTS core policy.
type: playbook
read_when:
  - Adding or reviewing `AGENTS.local.md` in a consumer repository.
  - Defining validation logic for local policy overlays.
code_paths: []
---

# Local Adaptation Policy

## Goal
Allow repository-local customization while preserving shared core guardrails.

## Allowed Local Adaptations
- Configuration inputs required by shared policy (for example `WORKTREE_MAIN_ROOT`).
- Repository-specific paths and project structure metadata.
- Repository-specific tooling notes that do not weaken shared workflow policy.
- Additional safety checks or stricter constraints.
- Toolchain/runtime specifics only when not already prescribed by shared core.
- Additional testing/documentation requirements.

## Forbidden Local Adaptations
- Weakening or removing core non-negotiables.
- Permitting destructive history/data operations by default.
- Removing required verification before push when core policy requires it.
- Replacing core precedence model with a permissive override model.
- Redefining shared worktree workflow rules or command contract locally.

## Recommended File Layout
- `AGENTS.local.md` should contain:
  - Repository context and toolchain defaults.
  - Required local config values (especially `WORKTREE_MAIN_ROOT`).
  - Local paths derived from shared config where needed.
  - Additive or stricter rules only; avoid restating shared policy.
  - Explicit cross-reference to this policy.
- Recommended section headings:
  - `## Local Config`
  - `## Local Paths` (optional)
  - `## Local Tooling` (optional)
  - `## Optional Additive Constraints` (optional)
  - `## References` (optional)
  - `## Waivers` (optional)

## Conflict Handling
- If local and core rules conflict, core wins unless an explicit user instruction in-thread says otherwise.
- If a local rule seems to weaken core policy, stop and escalate before implementation.

## Waivers (Optional)
- If consumer repos need exceptions, require a documented waiver with:
  - exact rule being waived
  - scope and duration
  - risk and mitigation
  - explicit approving authority
- Suggested `AGENTS.local.md` shape:
  - `## Waivers`
  - `### <waiver-id>`
  - `- \`rule\`: ...`
  - `- \`scope\`: ...`
  - `- \`duration\`: ...`
  - `- \`risk\`: ...`
  - `- \`mitigation\`: ...`
  - `- \`approved_by\`: ...`
- Validation expectation:
  - local overlays may declare waivers, but they still must not redefine shared worktree commands or silently weaken shared policy outside the documented waiver section.
