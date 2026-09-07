# Spec-Driven Development (SDD) Skill — Tutorial

**Tier:** 🟡 Weekly / Feature-start
**Type:** Skill (pipeline orchestrator — connects all other skills)
**Full skill:** `skills/spec-driven-development/SKILL.md`

---

## What It Is

**Spec-Driven Development (SDD)** is the discipline of making the spec the single source of truth — not the code, not the tests, not memory. Every artifact (tests, architecture, code) derives from and traces back to the spec.

This skill is the **pipeline orchestrator**: it tells you which skill to use at each stage, in what order, and what the gate is before moving forward.

---

## The 7-Stage Pipeline

```
Stage 0: Discover     → grill-me skill
Stage 1: Specify      → writing-specs skill        → docs/specs/feature.spec.md
Stage 2: QA Plan      → writing-qa-plan skill      → tasks/feature.qa-plan.md
Stage 3: Design       → software-design skill      → tasks/feature.design.md
Stage 4: Plan         → writing-implementation-plans → tasks/feature.plan.md
Stage 5: Build        → engineer / fast-worker agents
Stage 6: Confirm      → implementation-reviewer + code-reviewer + security-reviewer
Stage 7: Maintain     → writing-specs skill (maintain mode)
```

Each stage has a clear **gate** — a check you pass before moving forward.

---

## When to Run the Full Pipeline

| Feature | Minimum |
|---|---|
| **Large** (6+ files, complex) | All 7 stages |
| **Medium** (3-5 files) | Stages 1, 2, 4, 5, 6 |
| **Small** (1-2 files, clear) | Stage 1, 5, 6 |
| **Bug fix** | No pipeline needed |

---

## How to Invoke

**Start the pipeline:**
```
Use the spec-driven-development skill.
Feature: user data export (CSV, all user data, Settings page)
Complexity: medium
```

The skill walks you through each stage and tells you which skill/agent to call next.

**Or jump to a specific stage:**
```
Use the spec-driven-development skill — Stage 2 (QA Plan).
Spec: docs/specs/data-export.spec.md
```

**Claude Code / AGY:** "SDD pipeline for...", "spec-driven development for..." triggers it.

---

## A Complete Example: Data Export Feature

### Stage 0 — Discover
```
Use the grill-me skill. Feature idea: users should be able to export their data.
```
*Output: `tasks/2025-09-02-data-export.requirements.md`*

---

### Stage 1 — Specify
```
Use the writing-specs skill to create a spec.
Requirements: tasks/2025-09-02-data-export.requirements.md
```

*Output: `docs/specs/data-export.spec.md`*

```markdown
# Data Export Spec

## Overview
Logged-in users can export all their personal data as CSV.

## Requirements
### R1 — Export trigger
R1.1 — Export button on Settings → Data page
R1.2 — One active export per user at a time

### R2 — Content
R2.1 — Includes: transactions, profile, preferences
R2.2 — Excludes: payment card numbers (last 4 only)

### R3 — Delivery
R3.1 — <5s: immediate download
R3.2 — >5s: email link (valid 24h)

### R4 — Errors
R4.1 — Failure shows "Export failed. Try again." + retry button

## Acceptance Criteria
- [ ] Export downloads or email arrives correctly
- [ ] Sensitive fields excluded
- [ ] One export at a time enforced
```

**Gate ✓** — requirements numbered, acceptance criteria testable, no code in spec.

---

### Stage 2 — QA Plan
```
Use the writing-qa-plan skill.
Spec: docs/specs/data-export.spec.md
```

*Output: `tasks/2025-09-02-data-export.qa-plan.md`*

```markdown
TC-01 (MUST, traces to R3.1): Small export downloads within 3 seconds
TC-02 (MUST, traces to R3.2): Large export sends email link
TC-10 (MUST, traces to R4.1): Failed export shows retry option
TC-11 (SHOULD, traces to R1.2): Only one export active at a time
TC-20 (SHOULD, traces to R2.1): New user with no data exports headers-only CSV
```

**Gate ✓** — every test traces to a spec requirement.

---

### Stage 3 — Design
```
Use the software-design skill.
Spec: docs/specs/data-export.spec.md
QA Plan: tasks/2025-09-02-data-export.qa-plan.md
```

*Output: `tasks/2025-09-02-data-export.design.md`*

**Gate ✓** — design satisfies every spec requirement.

---

### Stage 4 — Plan
```
Use the writing-implementation-plans skill.
Spec: docs/specs/data-export.spec.md
Design: tasks/2025-09-02-data-export.design.md
```

*Output: `tasks/2025-09-02-data-export.plan.md`*

**Gate ✓** — every spec requirement covered by at least one task. Feature verification test included.

---

### Stage 5 — Build
Agents implement tasks from the plan. Reference spec when behavior is ambiguous.

---

### Stage 6 — Confirm
```
Use the implementation-reviewer agent.
Spec: docs/specs/data-export.spec.md
Files: src/export/

Use the code-reviewer agent on src/export/

Run QA plan: TC-01 through TC-20
```

**Gate ✓** — all acceptance criteria met, all QA test cases pass.

---

### Stage 7 — Maintain
When requirements change later:
```
Use the writing-specs skill (Maintain mode).
Spec: docs/specs/data-export.spec.md
Change: Users now want JSON format as an option (R5)
```

---

## The Traceability Chain

This is what SDD gives you that ad-hoc development doesn't:

```
Bug filed: "Export doesn't include preferences"
  ↓
Find it in spec: R2.1 — "Includes: transactions, profile, preferences"
  ↓
Find the QA test: TC-01 should have verified this
  ↓
Find the code: ExportBuilder.build() in src/export/builder.py
  ↓
Fix: preferences field was missing from field list
  ↓
Update spec if R2.1 was ambiguous, or update code if it wasn't
```

Every bug has a home in the spec. If it doesn't → the spec is incomplete → add it.

---

## Why This Matters for Solo Dev

Without SDD: you build what you think you want. 3 weeks later you realize you forgot the error states, the offline case, and the "one active export" constraint. You fix it, but now there are no tests for it.

With SDD: you caught all that in Stage 2 (QA Plan) before writing a single line of code. The tests exist. The spec is complete.

**The spec is the memory you don't trust yourself to have.**

---

## Time Investment (Medium Feature)

| Stage | Time |
|---|---|
| Discover (grill-me) | 15-20 min |
| Specify | 20-30 min |
| QA Plan | 15-20 min |
| Design | 30-45 min |
| Plan | 20-30 min |
| Build | (varies) |
| Confirm | 15-20 min |
| **Total overhead** | **~2 hours** |

Saves: features that don't match requirements, missing edge cases, no tests for critical paths, "I thought it was done" re-work.
