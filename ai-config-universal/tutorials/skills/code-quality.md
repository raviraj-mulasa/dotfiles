# Code Quality Skill — Tutorial

**Tier:** 🟡 Use Weekly (after messy sprints, before refactoring)
**Type:** Skill (you stay in the driver's seat)
**Full skill:** `skills/code-quality/SKILL.md`

---

## What It Does

Three separate workflows in one skill — pick the one you need:

1. **Pragmatic Review** — Is this design good? Does it click? Spawn the code-reviewer agent.
2. **Simplification** — Behavior-preserving clarity pass on recent changes
3. **SRP Redesign** — Clean-slate component analysis when something is doing too much

---

## When to Use It

- Code is getting complicated and you want to clean it up
- You finished a feature fast and now the code feels messy
- A function/class is getting long and you're not sure how to split it
- You want to simplify before someone else reads it (or before you forget it)

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/code-quality/SKILL.md — 
use the Simplification workflow on my recent changes in src/auth/
```

**Claude Code:**
```
Use the code-quality skill — specifically the SRP Redesign 
section — to analyze the UserService class. It's doing too much.
```

**AGY:** "Simplify...", "clean up...", "this class is doing too much..." triggers it.

---

## Workflow 1: Simplification

**Best for:** Making recent changes clearer without changing behavior.

What it removes:
- Nested conditionals → early returns
- Dead code (unreachable branches, unused imports)
- Redundant variables assigned and immediately returned
- Comments that lie or just restate the code
- Wrapper functions that just delegate with the same signature

What it **never** touches:
- Error handling (never removes catches or guards)
- Code outside the recent change scope
- Tests (test verbosity is intentional)

**Invoke:**
```
Use the code-quality simplification workflow on 
the changes in src/payments/ since the last commit.
```

**Result:** A diff of clarity improvements. Every change passes the "obviously better" test.

---

## Workflow 2: SRP Redesign

**Best for:** A class/module that's clearly doing too many things.

**The tell:** You can't describe what it does in one sentence without using "and".

**Example:**
```
UserService — handles user CRUD, sends welcome emails, 
validates permissions, AND formats user data for the API.
```
That's 4 responsibilities. SRP says it should have 1.

**Invoke:**
```
Use the code-quality SRP Redesign workflow on UserService 
in src/users/service.py
```

**Result:**
```
Proposed decomposition:

UserRepository — persist and retrieve users (DB only)
  Knows: database schema
  Does NOT know: email sending, permissions

UserNotifier — sends user-related emails  
  Knows: email templates, SMTP config
  Does NOT know: database, permission rules

PermissionChecker — evaluates access rights
  Knows: permission rules, role definitions
  Does NOT know: database, email

UserSerializer — formats user data for API responses
  Knows: API contract, field inclusion rules
  Does NOT know: database, email

Validation: change email template → touch UserNotifier only ✅
```

---

## Workflow 3: Pragmatic Review (Quick Design Check)

**Best for:** A quick sanity check — "does this design click?"

**The design click test:**
- Feels obvious and natural?
- Someone could understand it in 6 months without you?
- Changes are localized and predictable?

**If no** — it's too clever, too scattered, or too coupled.

**Invoke:**
```
Use the code-quality pragmatic review on the design of 
src/billing/ — does the abstraction make sense?
```

---

## Time Investment

- Simplification: 10-20 minutes per file
- SRP Redesign: 20-30 minutes, saves hours of future pain
- Design review: 5-10 minutes
