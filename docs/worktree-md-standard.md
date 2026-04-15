---
summary: Shared cross-repository standard for the canonical `worktree.md` context file in task worktrees.
type: doc
read_when:
  - Adopting workflow-core in a consumer repository.
  - Implementing worktree bootstrap, onboarding, or verification flows.
  - Defining how agents and UIs should resume worktree-local context.
code_paths:
  - AGENTS.core.md
  - playbooks/git/worktree-workflow.md
  - docs/workflow-core-usage.md
---

# `worktree.md` Standard

## Purpose
- `worktree.md` is the shared workflow-core standard for durable worktree-local context.
- It exists to answer two questions quickly in any consumer repository:
  - what remains to do in this worktree at a high level;
  - which plan documents are currently active for this worktree.
- It is intentionally narrow. It should not become a dump of raw git state, runtime state, logs, or full transcripts.

## Standard File Location
- File name: `worktree.md`
- Location: worktree root
- Example:

```text
<worktree-path>/worktree.md
```

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
- The text after the checkbox is the durable high-level todo label.
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
- Those files may supplement `worktree.md`, but they should not replace it as the canonical shared workflow-core worktree context file.
- If a repo bootstraps `worktree.md` from another file, the resulting `worktree.md` must still conform to this standard.

## Enforcement Model
We enforce this standard in layers:

1. Shared policy:
   - `AGENTS.core.md` makes `worktree.md` the default canonical worktree context file across consumer repositories.
2. Shared worktree workflow:
   - the worktree playbook requires `worktree.md` to stay current during normal task execution rather than as end-of-task cleanup.
3. Consumer bootstrap:
   - each consumer repository should ensure worktree creation or onboarding scaffolds `worktree.md` when it is missing.
4. Consumer tooling and UI:
   - agents, dashboards, and local tooling should read from and maintain `worktree.md` instead of inventing parallel context stores for the same purpose.
5. Final verification and handoff:
   - before final verification/push/handoff, `worktree.md` should exist and reflect current high-level todos plus active plan references.
6. Repository-local validation:
   - until a shared schema validator exists, consumer repositories should add any stricter checks they need in their own verification flow.

## Adoption Guidance
- New consumer repositories should adopt this standard directly.
- Existing consumer repositories that already use another worktree context file should migrate toward `worktree.md` and treat older files as supplemental during the transition.
- If a repository needs stricter rules, document them additively rather than redefining the shared baseline.
