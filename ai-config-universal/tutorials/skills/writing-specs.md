# Writing Specs Skill — Tutorial

**Tier:** 🔵 Situational (complex features, external stakeholders, or ambiguous requirements)
**Type:** Skill (you stay in the driver's seat)
**Full skill:** `skills/writing-specs/SKILL.md`

---

## What It Does

Creates a **functional specification** — the source of truth that every downstream artifact (design, tests, implementation) references. Written from the consumer's perspective: what they see, send, receive, experience. Not how it's built.

---

## When to Use It

- Feature is complex enough that you'll forget the requirements mid-build
- Multiple people need to agree on what's being built before work starts
- Requirements came from a conversation and you need to write them down precisely
- You need acceptance criteria to know definitively when you're "done"
- After a `grill-me` session — turn requirements into a formal spec

**Skip it for:** simple features you understand completely, bug fixes, refactoring.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/writing-specs/SKILL.md and create 
a spec for the user data export feature we discussed.
```

**Claude Code:**
```
Use the writing-specs skill to write a spec for 
the notification system. I want: email + in-app notifications,
user preferences per notification type, daily digest option.
```

**AGY:** "Write a spec for..." or "create a specification for..." triggers it.

---

## What a Spec Contains

```markdown
# Spec: User Data Export

## Overview
Logged-in users can export all their personal data as a CSV file.

## Requirements

### R1 — Export trigger
R1.1 — Export button on Settings → Data page (visible to all users)
R1.2 — One active export per user at a time (button disabled during generation)

### R2 — Content
R2.1 — Includes: all transactions, profile fields, notification preferences
R2.2 — Excludes: payment card numbers (last 4 only), internal system IDs

### R3 — Delivery
R3.1 — Exports completing in <5s: file downloads immediately
R3.2 — Exports taking >5s: "We'll email you a link" shown; link valid 24h

### R4 — Error handling
R4.1 — If export fails: user sees "Export failed. Try again." with retry button
R4.2 — Partial exports are never delivered — all or nothing

## Out of Scope (v1)
- Multiple format options (JSON, XML)
- Scheduled/recurring exports
- Bulk export for admins
```

---

## The Numbering System

Every requirement gets a number (R1, R1.1, R1.2). This means:
- Tests reference specific requirements: `test_r3_1_small_export_downloads_immediately()`
- QA plans trace to requirements: "TC-03 traces to R3.1"
- You know exactly which requirement a bug violates

---

## Spec vs Implementation Plan

| Spec | Implementation Plan |
|---|---|
| WHAT the feature does | HOW it's built |
| Consumer perspective | Engineering perspective |
| No code | Pseudocode + data models |
| Lives in `docs/specs/` | Lives in `tasks/` |
| Written before design | Written before coding |

---

## Time Investment

- Writing spec: 20-40 minutes
- Saves: misaligned expectations, features that don't match requirements, unclear "done" criteria
