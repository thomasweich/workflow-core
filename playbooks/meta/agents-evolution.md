---
summary: High-bar workflow for evolving AGENTS policy while keeping it stable, concise, and enforceable.
type: playbook
read_when:
  - Proposing a change to AGENTS policy.
  - Deciding whether a process learning should become binding policy.
  - Communicating a policy change to collaborators.
code_paths:
  - AGENTS.core.md
  - playbooks/meta/agents-evolution.md
---

# AGENTS Evolution Playbook

## Objective
Keep AGENTS policy compact, enforceable, and high-signal. Treat it as binding policy, not a running notes file.

## Policy Funnel
Use a two-tier policy funnel:
1. Capture ideas in a repo-local candidates log (for example `playbooks/meta/agents-candidates.md`) as non-binding proposals.
2. Promote only proven, high-impact rules into AGENTS policy as binding requirements.

## Tier 1: Candidate Backlog (Lower Bar)
Add a candidate entry when any of the following occurs:
- a task caused avoidable rework
- a near miss exposed workflow risk
- recurring confusion appears but root cause is not yet proven

Candidate entries are for evaluation and experimentation. They do not change required behavior until promoted.
Each repo should define the exact candidate-log schema locally.

## Tier 2: AGENTS Promotion (Higher Bar)
Promote a candidate into AGENTS policy only when one of these is true:
- It prevents a severe risk, even if seen once (history loss, security leak, production-impacting failure).
- It has repeated in 2+ independent tasks or agents and the rule would materially reduce rework or risk.
- It is foundational for workflow consistency across most tasks.

And all of these must be true:
- Rule is a one-line imperative.
- Rule is observable or testable in normal execution.
- Rule does not conflict with existing AGENTS policy.
- Detailed rationale and examples live in playbooks, not AGENTS itself.

## Notification Requirement
Whenever AGENTS policy changes:
1. Notify the user in-thread that policy changed, with a short before/after summary.
2. Include a policy-change note in the commit message body:
   - trigger
   - rule added, changed, or removed
   - expected impact
3. If the change was not a direct user-instructed AGENTS edit, update the repo-local candidates log status for the promoted or retired item.
4. If step 3 applies, record the AGENTS reference and commit hash in the candidate entry.

## Update Procedure
1. If not a direct user-instructed AGENTS edit, add or update the repo-local candidate entry with required fields.
2. Edit AGENTS policy minimally for approved promotions.
3. Remove, merge, or simplify conflicting rules in the same change.
4. Validate the relevant docs or playbooks metadata in the consumer repo.
5. Commit with the policy-change note in the commit body.
6. If step 1 applies, update the candidate entry with final status, decision date, AGENTS reference, and commit hash.
7. Notify the user in-thread with file references and commit hash.

## Pruning Policy
Review AGENTS policy periodically and remove rules that are:
- obsolete due to workflow or tooling changes
- duplicated by newer, clearer rules
- too detailed for a compact policy file

Move removed detail into playbooks when historical context is still useful.
