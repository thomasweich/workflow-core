---
summary: Shared cross-repository standard for the local-only `worktree.md` context file in task worktrees.
type: doc
read_when:
  - Adopting workflow-core in a consumer repository.
  - Implementing worktree bootstrap, onboarding, or verification flows.
  - Defining how agents and UIs should resume worktree-local context.
code_paths:
  - AGENTS.core.md
  - playbooks/git/worktree-workflow.md
  - docs/workflow-core-usage.md
  - templates/worktree.md
---

# `worktree.md` Standard

## Purpose
- `worktree.md` is the shared workflow-core standard for worktree-local context.
- It exists to answer two questions quickly in any consumer repository:
  - what remains to do in this worktree at a high level;
  - which plan documents are currently active for this worktree.
- It is intentionally narrow and local-only. It should not become a dump of raw git state, runtime state, logs, or full transcripts.
- It is not a durable cross-branch planning artifact. Durable project state belongs in tracked plans, product docs, repository docs, issues, or code.

## Standard File Location
- File name: `worktree.md`
- Location: worktree root
- Example:

```text
<worktree-path>/worktree.md
```

## Source Control Contract
- Root `worktree.md` is operational state and should not be committed.
- Consumer repositories should add `/worktree.md` to their repository-root `.gitignore`.
- The tracked source-controlled artifact is the scaffold template at `templates/worktree.md`, plus this standard.
- Worktree creation, onboarding, and local UIs may create or update the ignored root `worktree.md` in each worktree.
- Agents should not stage or commit `worktree.md`. If its content needs to be preserved beyond the current worktree, move that information into a tracked plan, product doc, repository doc, issue, or code change.

## Minimum Required Sections
- `# Todos`
- `# Active Plans`

These headings are the shared cross-repository baseline. Consumer repositories may add more sections, but should not silently change the meaning of these two.

### Accepted Alias Headings
- `# Todo` may be accepted as an alias for `# Todos`
- `# Plans` may be accepted as an alias for `# Active Plans`

### Allowed Additional Sections
Common optional sections include:
- `# Purpose`
- `# Summary`
- `# Key References`

Consumer repositories may define additional additive sections when needed.

## `# Todos` Contract
- Todos should be markdown task-list items.
- Supported bullet prefixes: `-`, `*`, `+`
- Supported states:
  - unchecked: `[ ]`
  - checked: `[x]` or `[X]`
- The text after the checkbox is the structured high-level todo label.
- Open todos should describe the current remaining slices of work in this worktree, not broad multi-phase initiatives.
- Broad goals such as a full redesign, re-architecture, or migration theme belong in plan documents; `worktree.md` should keep only the next unfinished slices that remain after each milestone lands.
- After a milestone commit, reconcile `worktree.md` so completed umbrella items are removed or replaced with the next still-open slice.
- Non-task-list lines under `# Todos` are allowed, but consumers should not rely on them as structured workflow state unless they document stricter local rules.

### Example
```md
# Todos

- [ ] Finish the runtime control surface
- [ ] Reconcile the active plan references
- [x] Rebase onto latest `main`
```

## `# Active Plans` Contract
- Active plans should be references to markdown documents relevant to the selected worktree.
- Each item may be either:
  - a markdown link, or
  - a plain relative path to a markdown file
- Paths should stay inside the worktree/repository checkout.
- Absolute paths and parent traversal such as `../` should not be used.
- Non-markdown targets should not be treated as active plan entries.

### Example
```md
# Active Plans

- [Product Plan](product/2026-04-04-wfo-core-features-product-plan.md)
- [Implementation Plan](plans/2026-04-13-wfo-agent-restart-survival-plan.md)
- docs/operational-context.md
```

## Relationship To Repo-Local Files
- Consumer repositories may keep additional local context files such as `WORKTREE.local.md`.
- Those files may supplement `worktree.md`, but they should not replace it as the standard shared workflow-core worktree context file.
- If a repo bootstraps `worktree.md` from another file, the resulting local `worktree.md` must still conform to this standard.

## Enforcement Model
We enforce this standard in layers:

1. Shared policy:
   - `AGENTS.core.md` makes local-only `worktree.md` the default worktree context file across consumer repositories.
2. Shared worktree workflow:
   - the worktree playbook requires local `worktree.md` to stay current during normal task execution rather than as end-of-task cleanup.
3. Consumer bootstrap:
   - each consumer repository should ignore root `worktree.md` and ensure worktree creation or onboarding scaffolds it when it is missing.
4. Consumer tooling and UI:
   - agents, dashboards, and local tooling should read from and maintain local `worktree.md` instead of inventing parallel context stores for the same purpose.
5. Final verification and handoff:
   - before final verification/push/handoff, local `worktree.md` should reflect current high-level todos plus active plan references, but it should remain uncommitted.
6. Repository-local validation:
   - until a shared schema validator exists, consumer repositories may add any stricter local-file checks they need in their own verification flow.
7. Shared warning signal:
   - shared `verify-integration` may emit warnings for obviously broad umbrella todos so stale top-level work is noticed earlier without relying on brittle hard-fail heuristics.

## Adoption Guidance
- New consumer repositories should adopt this standard directly.
- Existing consumer repositories that already use another worktree context file should migrate toward `worktree.md` and treat older files as supplemental during the transition.
- If a repository needs stricter rules, document them additively rather than redefining the shared baseline.
- Existing consumer repositories that tracked root `worktree.md` should remove it from the index with `git rm --cached worktree.md`, add `/worktree.md` to `.gitignore`, and keep any still-useful content in the local ignored file or move durable items into tracked planning artifacts.
