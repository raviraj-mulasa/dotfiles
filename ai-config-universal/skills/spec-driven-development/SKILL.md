---
name: spec-driven-development
description: >
  End-to-end Spec-Driven Development (SDD) pipeline orchestrator. Enforces the discipline:
  spec first, then QA plan, then design, then implementation. The spec is the single source
  of truth — every downstream artifact (tests, architecture, code) derives from and traces
  back to it. Use when starting any non-trivial feature, or when retrofitting SDD onto an
  existing codebase. Covers full pipeline from fuzzy idea to verified implementation.
---

# Spec-Driven Development (SDD)

## The Core Discipline

**The spec is the single source of truth.**

Not the code. Not the tests. Not what you remember from the meeting. The spec.

If the spec is wrong → everything downstream is wrong.
If the spec is missing → agents guess, guesses compound, features drift.
If you write code before the spec → you'll write a spec that describes the code you wrote, not what the user needs.

**The rule:** No code without a spec. No test without a spec reference. No agent task without a spec to work from.

---

## The Pipeline

Every non-trivial feature travels this pipeline in order. Don't skip stages.

```
Stage 0: Discover          → fuzzy idea → clear requirements
Stage 1: Specify           → requirements → formal spec
Stage 2: Verify (pre-code) → spec → QA plan (test cases before design)
Stage 3: Design            → spec + QA plan → architecture
Stage 4: Plan              → design → implementation plan (task breakdown)
Stage 5: Build             → plan → code (agents execute tasks)
Stage 6: Confirm           → code → verify against spec + QA plan
Stage 7: Maintain          → spec stays current as code evolves
```

---

## Stage 0: Discover (Optional but Recommended)

**When:** Idea is fuzzy. "I want users to be able to export their data" — what does that actually mean?

**Skill:** `grill-me`

**What it produces:** `tasks/YYYY-MM-DD-feature.requirements.md`

```
Use the grill-me skill. I want to add [feature idea].
```

**Gate to Stage 1:** Every requirement traces to something the user said or confirmed. No invented requirements. Open questions documented.

---

## Stage 1: Specify

**When:** Requirements are clear (from discovery or from your own understanding).

**Skill:** `writing-specs`

**What it produces:** `docs/specs/feature-name.spec.md`

```
Use the writing-specs skill to create a spec for [feature].
Requirements source: tasks/2025-09-02-feature.requirements.md
```

**The spec format:**

```markdown
# Feature Name Spec

## Overview
[What this is, who it's for, what problem it solves. 2-3 sentences.]

## Requirements

### R1 — [Area Name]
R1.1 — [Specific behavior, written from consumer perspective]
R1.2 — [Another behavior]
R1.3 — [Edge case behavior]

### R2 — Error Handling
R2.1 — [What user sees when X fails]
R2.2 — [What system does when Y is invalid]

## Out of Scope
- [Explicitly excluded things — prevents scope creep]
- [Things planned for later]

## Open Questions
- [OPEN] [Unresolved decision with context]

## Acceptance Criteria
- [ ] [Testable statement 1]
- [ ] [Testable statement 2]
```

**The test:** Could you hand this spec to a competent engineer who knows nothing about the codebase, and they'd build something with identical user-facing behavior? If no — the spec is incomplete.

**Gate to Stage 2:** Every requirement is numbered. Every acceptance criterion is testable. Out of scope is explicit. No implementation details.

---

## Stage 2: Verify (QA Plan — Before Design)

**When:** Spec is approved.

**Skill:** `writing-qa-plan`

**Why before design?** If you write test cases after looking at the implementation, you test the implementation. Written from the spec, you test the behavior.

**What it produces:** `tasks/YYYY-MM-DD-feature.qa-plan.md`

```
Use the writing-qa-plan skill to derive test cases 
from docs/specs/feature-name.spec.md
```

**The QA plan structure:**

```markdown
# QA Plan: Feature Name

Source: docs/specs/feature-name.spec.md (v1.0)

## TC-01 to TC-09 — Happy Path
## TC-10 to TC-19 — Error Handling  
## TC-20 to TC-29 — Edge Cases
## TC-30 to TC-39 — Performance (if applicable)
## TC-40 to TC-49 — Security (if applicable)

Each test case:
  Given: [precondition]
  When:  [action]
  Then:  [observable outcome — specific and measurable]
  Traces to: R1.2 [spec requirement]
```

**Gate to Stage 3:** Every test case traces to a spec requirement. No orphan tests. No implementation details in test cases.

---

## Stage 3: Design

**When:** Spec + QA plan both exist.

**Skill:** `software-design`

**What it produces:** `tasks/YYYY-MM-DD-feature.design.md`

```
Use the software-design skill to design [feature].
Spec: docs/specs/feature-name.spec.md
QA Plan: tasks/2025-09-02-feature.qa-plan.md
```

The design defines architecture, component contracts, and data models. It answers HOW to build what the spec says WHAT to build.

**Gate to Stage 4:** Design satisfies every spec requirement. Components have explicit contracts (GUARANTEES, EXPECTS, FAILURE BEHAVIOR). QA test cases are achievable with this design.

---

## Stage 4: Plan

**When:** Design is approved.

**Skill:** `writing-implementation-plans`

**What it produces:** `tasks/YYYY-MM-DD-feature.plan.md`

```
Use the writing-implementation-plans skill to create 
an execution plan.
Spec: docs/specs/feature-name.spec.md
Design: tasks/2025-09-02-feature.design.md
```

The plan is backbone-only: data model schemas, method signatures, orchestration flow, task breakdown. Not implementation.

**Gate to Stage 5:** Every spec requirement is covered by at least one task. Feature verification test (mandatory) is included as a task.

---

## Stage 5: Build

**When:** Plan is approved.

**Agents:** `engineer`, `fast-worker`, `sprint-dev` (for multi-agent parallel execution)

Agents implement tasks from the plan. Each task has a `Verify` step — a concrete check that runs before moving to the next task.

**The rule:** Agents read the spec, not just the plan. When in doubt about behavior, the spec is the answer.

```
Use the engineer agent to implement Task 3 from 
tasks/2025-09-02-feature.plan.md
Spec for reference: docs/specs/feature-name.spec.md
```

**Gate to Stage 6:** All plan tasks complete. All task verifications pass.

---

## Stage 6: Confirm

**When:** Implementation is done.

Run all three in sequence:

**6a — Completeness check:**
```
Use the implementation-reviewer agent.
Feature: [name]
Spec: docs/specs/feature-name.spec.md
Modified files: [list]
```
*Checks: did the implementation cover everything in the spec?*

**6b — Quality check:**
```
Use the code-reviewer agent on [modified files].
Spec for reference: docs/specs/feature-name.spec.md
```
*Checks: is the implementation well-structured?*

**6c — Security check (if applicable):**
```
Use the security-reviewer agent on [modified files].
```

**6d — QA verification:**
Execute the QA plan test cases (TC-01 through TC-XX).
Every test case must pass. Every `Traces to: Rn.n` must be verifiable.

**Gate to done:** All acceptance criteria in the spec are met. All QA plan test cases pass. No HIGH/CRITICAL findings from reviewers.

---

## Stage 7: Maintain

**The spec is a living document.** When requirements change:

```
Use the writing-specs skill (Maintain mode).
Spec: docs/specs/feature-name.spec.md
Change: [describe what changed and why]
```

**Rules:**
- Every spec change gets a dated changelog entry
- Requirements that change get new revision markers (R1.2 → R1.2.1)
- QA plan updates to reflect changed requirements
- Implementation that diverges from spec → update the spec (or fix the implementation)

---

## Spec File Organization

```
docs/
  specs/
    README.md              ← spec index (list all specs + status)
    auth.spec.md           ← one spec per functional area
    notifications.spec.md
    data-export.spec.md
    
tasks/
  YYYY-MM-DD-feature.requirements.md   ← Stage 0 output
  YYYY-MM-DD-feature.qa-plan.md        ← Stage 2 output
  YYYY-MM-DD-feature.design.md         ← Stage 3 output
  YYYY-MM-DD-feature.plan.md           ← Stage 4 output
```

---

## The Traceability Chain

Every artifact traces back to the spec. This is what makes SDD debuggable:

```
Spec requirement R2.3
  ↓ traced by
QA Plan TC-12 (Given user is offline, When: export triggered, Then: error shown)
  ↓ implemented by
Implementation: ExportService.handle_offline_case() in src/export/service.py:L89
  ↓ verified by
Test: test_export_shows_error_when_offline() in tests/test_export.py:L234
```

If a bug is filed → find it in the spec → find the QA test case → find the implementation → find the unit test. The chain is complete.

If a bug exists with no spec requirement → the spec is missing that case. Add it. Don't just fix the code.

---

## Anti-Patterns

❌ **Code-first specs:** Writing a spec that describes the code you already wrote.
→ Spec becomes documentation, not a source of truth.

❌ **Implementation details in specs:** "The system shall call `PaymentService.process()`"
→ Specs describe behavior, not code. The implementation is free to change.

❌ **Orphan test cases:** Tests with no spec requirement reference.
→ Tests that pass but prove nothing about requirements.

❌ **Orphan requirements:** Spec requirements with no test cases.
→ Untested requirements that may silently regress.

❌ **Stale specs:** Code changed but spec wasn't updated.
→ The spec is now a lie. Future agents will build the wrong thing.

---

## Shorthand for Solo Developers

You don't have to run the full pipeline for every feature. Scale to complexity:

| Feature size | Minimum pipeline |
|---|---|
| Small (1-2 files, clear behavior) | writing-specs → code → code-reviewer |
| Medium (3-5 files, some edge cases) | grill-me → writing-specs → writing-qa-plan → writing-implementation-plans → code |
| Large (6+ files, complex behavior) | Full pipeline: Stages 0-7 |
| Bug fix | No spec needed (unless root cause reveals missing spec requirement) |
