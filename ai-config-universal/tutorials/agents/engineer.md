# Engineer Agent — Tutorial

**Tier:** 🟢 Core / Default (Reasoning Workhorse)
**Type:** Agent (hands off the task completely)
**Full agent:** `agents/engineer.md`

---

## What It Does

The **default reasoning workhorse** for non-trivial tasks. Use for implementation, refactoring, architecture analysis, investigation, and complex code reviews. It balances deep capability with practical restraint.

---

## When to Use It

- Writing complex logic, models, or algorithms
- Refactoring tangled code across modules
- Investigating non-obvious bugs or architectural trade-offs
- Executing detailed implementation plans

**Don't use it for:** purely mechanical tasks (like grep or running a test command) — use `fast-worker` to save cost/tokens.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Act as the engineer defined in agents/engineer.md. 
Implement the webhook retry logic according to tasks/webhook.plan.md.
```

**Claude Code:**
```
Use the engineer agent to implement the user profile update endpoint per docs/specs/profile.spec.md
```

**AGY:** Automatically routes reasoning tasks to the `engineer` tier.

---

## Operating Rules

1. **Stay within scope**: Solves the assigned problem without unsolicited structural redesigns.
2. **Flag unexpected anomalies**: If it spots unrelated bugs or broken patterns, it reports them alongside results rather than silently refactoring them.
3. **Show reasoning when it matters**: Concrete code and architectural rationale.
