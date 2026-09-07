---
name: writing-qa-plan
description: Derive functional test cases from spec before design. Tests what the feature SHOULD DO, not how it's built. Creates acceptance criteria that verify user-facing behavior. Use when a spec is approved and the feature has user-facing behavior to verify.
---

# Writing QA Plans

**Purpose:** Create QA plan documents (`*.qa-plan.md`) that define functional test cases derived from the spec, BEFORE design work begins.

## When to Use This Skill

**USE when:**
- Spec is approved and ready for design
- Feature has user-facing behavior to verify
- Multiple acceptance criteria need formal test cases
- Need clear pass/fail criteria for QA handoff

**SKIP when:**
- Pure refactoring (no behavior change)
- Internal tooling with no user impact
- Bug fixes with obvious verification
- Simple features where spec acceptance criteria suffice

---

## Document Hierarchy

```
spec.md        (WHAT we need)
    ↓
qa-plan.md     (HOW to verify it)  ← THIS SKILL
    ↓
design.md      (HOW we'll build it)
    ↓
plan.md        (EXECUTION details)
```

This is the **SECOND document.** It bridges requirements to design by defining what "done" looks like BEFORE you decide how to build it.

---

## Core Principle: Test Behavior, Not Implementation

> If you write test cases AFTER looking at implementation, you test the implementation.
> If you write test cases FROM the spec, you test the behavior.

**Test cases should remain valid even if implementation changes completely.**

| BAD (Implementation) | GOOD (Behavior) |
|---------------------|-----------------|
| "Verify `process_queue()` method called" | "Verify items processed within 5 seconds" |
| "Check database has 3 rows" | "Verify user sees 3 items in list" |
| "Assert `ValidationError` raised" | "Verify error message shows 'Invalid input'" |
| "Mock `APIClient.fetch()` returns data" | "Verify data loads when page opened" |

**Focus on:** inputs (what user provides), outputs (what user observes), behavior (what system does).

**Never reference:** class names, function names, database tables, internal state, private variables.

---

## Required Sections

### 1. Source Reference
Link to the spec this QA plan derives from.

```markdown
## Source
- **Spec:** [./tasks/2025-01-15-feature.spec.md]
- **Version:** v1.0 (approved date)
```

### 2. Feature Summary
2-3 sentences. What user capability is being tested?

### 3. Test Scenarios by Category

Use these ID ranges:

| Category | ID Range | Purpose |
|----------|----------|---------|
| Happy Path | TC-01 to TC-09 | Normal successful usage |
| Error Handling | TC-10 to TC-19 | Expected failures, validation |
| Edge Cases | TC-20 to TC-29 | Boundary conditions |
| Performance | TC-30 to TC-39 | Speed, scale (if applicable) |
| Security | TC-40 to TC-49 | Auth, permissions (if applicable) |

### 4. Test Case Format

Each test case MUST follow this structure:

```markdown
### TC-XX: [Descriptive Name]
**Priority:** MUST | SHOULD | COULD
**Traces to:** [spec section or acceptance criterion]
**Given:** [Preconditions/Setup]
**When:** [Action taken]
**Then:** [Expected observable outcomes — be specific]
```

### 5. Out of Scope
What this QA plan does NOT cover.

---

## Anti-Patterns

❌ **Referencing implementation details:**
```
Then: BarcodeService.lookup() returns Equipment object
```

✅ **Testing observable behavior:**
```
Then: Equipment details screen displays with serial number visible
```

❌ **Vague outcomes:**
```
Then: System handles the error gracefully
```

✅ **Specific, measurable outcomes:**
```
Then:
- Error message "Barcode not recognized" displayed
- "Scan Again" button visible
- User remains on scan screen
```

❌ **Testing only happy path** — missing error cases, edge cases

✅ **Balanced coverage** across happy path, errors, and edge cases

---

## Traceability

**Every test case MUST trace to a spec requirement.**

This ensures:
- No orphan tests (tests without requirements)
- No untested requirements (requirements without tests)
- Clear impact analysis when requirements change

---

## Priority Levels

| Priority | Meaning | Action |
|----------|---------|--------|
| **MUST** | Feature doesn't work without this | Block release if fails |
| **SHOULD** | Important functionality | Fix before GA |
| **COULD** | Nice to have | Fix if time permits |

---

## Constraints

| Constraint | Limit |
|------------|-------|
| Total length | ≤250 lines |
| Test cases | 15-25 typical |
| Implementation details | NONE |
| Code references | NONE |

---

## Output Location

**Pattern:** `./tasks/YYYY-MM-DD-<title>.qa-plan.md`

---

## Self-Check Before Saving

- [ ] Source spec linked?
- [ ] Feature summary describes user capability (not implementation)?
- [ ] All test cases use Given/When/Then format?
- [ ] All test cases have Priority and Traces to?
- [ ] Happy path covered (TC-01 to TC-09)?
- [ ] Error handling covered (TC-10 to TC-19)?
- [ ] Edge cases covered (TC-20 to TC-29)?
- [ ] Performance tests if applicable (TC-30+)?
- [ ] Security tests if applicable (TC-40+)?
- [ ] NO implementation details (class names, functions, DB tables)?
- [ ] All outcomes specific and measurable?
- [ ] Every test case traces to a spec requirement?
- [ ] Out of scope section present?
- [ ] ≤250 lines?

If ANY is NO → Fix before saving.

---

## Final Note

QA plans written from specs test what users need.
QA plans written from code test what developers built.

Write from the spec. Test the behavior. Ship confidence.
