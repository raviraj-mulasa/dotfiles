# Writing Implementation Plans — Tutorial

**Tier:** 🟢 Use Every Day (before any multi-file change)
**Type:** Skill (you stay in the driver's seat)
**Full skill:** `skills/writing-implementation-plans/SKILL.md`

---

## What It Does

Creates a **backbone plan** before you write any code. Defines *what* to build and *why*, so you don't figure it out mid-implementation and get stuck or go sideways.

The plan has two jobs: let a human review the approach, and serve as your execution map.

---

## When to Use It

**Always use it when:**
- Feature touches 3+ files
- You're creating new models, API endpoints, or pipelines
- You're doing an architectural change or refactor

**Skip it for:**
- Single-file changes
- Bug fixes
- Exploration/investigation

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/writing-implementation-plans/SKILL.md 
and create an implementation plan for: [describe the feature]
```

**Claude Code:**
```
Use the writing-implementation-plans skill to plan the 
[feature name] before we start coding.
```

**AGY:** "Create an implementation plan for..." triggers it.

---

## What Happens

The AI produces a `tasks/YYYY-MM-DD-feature.plan.md` with:

| Section | What it contains |
|---|---|
| **Purpose** | Why this exists (2-3 sentences) |
| **File tree** | Which files will be created/modified |
| **Data models** | Schemas and types — no implementation |
| **Orchestration** | A→B→C flow in pseudocode |
| **Boundaries** | What's IN scope, OUT of scope, must not change |
| **Pre-decisions** | Ambiguities resolved now, not mid-coding |
| **Testing strategy** | Including the mandatory feature verification test |
| **Acceptance criteria** | Testable statements for "done" |
| **Task breakdown** | 2-5 minute tasks with dependencies |

---

## Real Example

**You:**
```
Use the writing-implementation-plans skill to plan adding 
rate limiting to the login endpoint.
```

**AI produces plan including:**
```
## Boundaries

IN SCOPE:
- Add rate limiting middleware to POST /auth/login
- Add Redis-backed counter per IP
- Return 429 with Retry-After header when limit exceeded

OUT OF SCOPE:
- NOT adding rate limiting to other endpoints (future work)
- NOT implementing IP allowlisting

MUST NOT CHANGE:
- Existing auth logic in src/auth/login.py
- Session token format

## Pre-Decisions

Decision: Storage for rate limit counters
Options: A) Redis  B) In-memory  C) Database
Choice: Redis
Rationale: In-memory resets on restart; DB is too slow; Redis is the right tool.

## Testing Strategy

FEATURE TEST: test_login_blocked_after_5_attempts()
- Call POST /auth/login 6 times with wrong password
- Assert 6th returns 429 with Retry-After header
- THIS PROVES THE FEATURE WORKS.
```

---

## The Key Insight

**The plan is backbone only — not implementation.**

✅ Good: `def process(items: List[Item]) -> List[Result]:` + 3-line pseudocode
❌ Bad: Full implementation with loops, variable names, try/except

You fill in the leaves during implementation. The plan defines the skeleton.

---

## Time Investment

- Writing the plan: 15-30 minutes
- Saves: 2-4 hours of mid-implementation confusion and rework
