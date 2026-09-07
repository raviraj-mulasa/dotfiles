# Writing QA Plan Skill — Tutorial

**Tier:** 🔵 Situational (when a feature has multiple user-facing behaviors to verify)
**Type:** Skill (you stay in the driver's seat)
**Full skill:** `skills/writing-qa-plan/SKILL.md`

---

## What It Does

Creates a **QA plan** — formal test cases derived from your spec, written *before* design starts. Tests what the feature **should do** (behavior), not how it's built (implementation).

---

## When to Use It

- You have an approved spec and need to define what "done" looks like
- Feature has multiple behaviors: happy path, errors, edge cases, performance
- You want formal acceptance criteria before writing a single line of code
- You want to know what to manually verify before shipping

**Skip it for:** pure refactoring (no behavior change), simple bug fixes, features where the spec acceptance criteria are sufficient.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/writing-qa-plan/SKILL.md and create 
a QA plan for the user data export spec in 
tasks/2025-09-02-data-export.spec.md
```

**Claude Code:**
```
Use the writing-qa-plan skill to derive test cases 
from the notification system spec.
```

---

## What a QA Plan Looks Like

```markdown
# QA Plan: User Data Export

Source: tasks/2025-09-02-data-export.spec.md (v1.0)

## Happy Path (TC-01 to TC-09)

### TC-01: Small export downloads immediately
Priority: MUST | Traces to: R3.1
Given: User has <100 transactions, is on Settings → Data page
When: User clicks "Export My Data"
Then:
- CSV file download begins within 3 seconds
- File named "my-data-2025-09-02.csv"
- File contains all transactions and profile data

### TC-02: Large export sends email link
Priority: MUST | Traces to: R3.2
Given: User has >10,000 transactions
When: User clicks "Export My Data"
Then:
- "We'll email you a link" message appears immediately
- Email arrives within 5 minutes with download link
- Link downloads the complete CSV

## Error Handling (TC-10 to TC-19)

### TC-10: Export failure shows retry option
Priority: MUST | Traces to: R4.1
Given: Export service is unavailable
When: User clicks "Export My Data"
Then:
- "Export failed. Try again." message shown
- Retry button visible and functional
- No partial file downloaded

### TC-11: Only one export at a time
Priority: SHOULD | Traces to: R1.2
Given: User has an export already in progress
When: User navigates to Settings → Data
Then:
- Export button is disabled/greyed out
- "Export in progress" message shown

## Edge Cases (TC-20 to TC-29)

### TC-20: User with no data
Priority: SHOULD | Traces to: R2.1
Given: Brand new user with no transactions
When: User clicks "Export My Data"
Then:
- CSV downloads with headers only (no data rows)
- File is not empty — contains column headers
```

---

## The Key Distinction

| BAD (implementation) | GOOD (behavior) |
|---|---|
| "Verify `export_service.run()` called" | "Verify CSV file downloads within 3 seconds" |
| "Check S3 bucket has 1 new object" | "Verify email link arrives within 5 minutes" |
| "Assert `ExportError` raised" | "Verify 'Export failed. Try again.' message shown" |

If you write test cases after looking at the code, you test the implementation.
If you write test cases from the spec, you test the behavior.

---

## Time Investment

- Writing QA plan: 20-30 minutes
- Saves: discovering missing behaviors after shipping, unclear acceptance criteria
