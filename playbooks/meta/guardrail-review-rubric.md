---
summary: Rubric for prompt-based review of shared-core versus local workflow instructions.
type: playbook
read_when:
  - Reviewing whether local workflow instructions conflict with shared-core.
  - Deciding whether a workflow instruction belongs in shared-core, local files, or a thin wrapper.
  - Running `scripts/workflow/review-guardrails`.
code_paths:
  - AGENTS.core.md
  - AGENTS.local.template.md
  - scripts/workflow/review-guardrails
---

# Guardrail Review Rubric

## Goal
Review workflow instruction files for:
- conflicts between shared-core and local instructions
- unresolved items that need human or agent cleanup
- placement mistakes, where an instruction lives in the wrong layer

## Primary Questions
1. Does any local instruction weaken, contradict, or redefine shared-core policy?
2. Does any shared or local instruction require resolution before the workflow integration is considered clean?
3. Does each instruction live in the right layer:
   - shared-core
   - local overlay or supplement
   - thin local wrapper pointing at shared-core

## Placement Rules
Instructions should usually live in shared-core when they are:
- repository-independent
- reusable across multiple repositories
- part of the shared command contract or policy model
- shared planning, testing, or AGENTS-governance workflows

Instructions should usually stay local when they are:
- repository configuration values such as `WORKTREE_MAIN_ROOT`
- repository-specific tooling notes
- repository-specific rollout or migration runbooks
- local candidate logs or other repo-owned governance history
- command catalogs tied to the repo's actual toolchain

Thin local wrappers are the right pattern when:
- the canonical workflow guidance is shared-core
- the local file only points to shared-core and adds a small repo-specific supplement

## Severity Rules
Return `fail` when:
- local instructions weaken shared non-negotiables
- local files redefine shared `scripts/worktree` behavior
- local guidance introduces dangerous git or verification behavior
- conflicting instructions create two authorities that would change behavior
- a placement problem clearly needs an edit now, not later

Return `warn` when:
- an instruction is in the wrong place but not currently conflicting
- duplication increases maintenance risk even if behavior still matches
- placement is ambiguous enough that a cleanup decision should be made

Return `pass` when:
- no shared versus local conflict exists
- no immediate resolution is needed
- instruction placement is appropriate or only trivially duplicative

## Do Not Flag These By Themselves
- generated `AGENTS.md` snapshots that include shared-core content
- thin local wrappers that point to shared-core
- local tooling notes that do not change workflow policy
- repo-specific supplements that are intentionally local
