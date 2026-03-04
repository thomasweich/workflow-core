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
- Repository-specific paths, commands, and project structure.
- Additional safety checks or stricter constraints.
- Toolchain/runtime specifics for that repository.
- Additional testing/documentation requirements.

## Forbidden Local Adaptations
- Weakening or removing core non-negotiables.
- Permitting destructive history/data operations by default.
- Removing required verification before push when core policy requires it.
- Replacing core precedence model with a permissive override model.

## Recommended File Layout
- `AGENTS.local.md` should contain:
  - Repository context and toolchain defaults.
  - Local workflow commands and paths.
  - Additive or stricter rules only.
  - Explicit cross-reference to this policy.

## Conflict Handling
- If local and core rules conflict, core wins unless an explicit user instruction in-thread says otherwise.
- If a local rule seems to weaken core policy, stop and escalate before implementation.

## Waivers (Optional)
- If consumer repos need exceptions, require a documented waiver with:
  - exact rule being waived
  - scope and duration
  - risk and mitigation
  - explicit approving authority
