# Code Reviewer Agent — Tutorial

**Tier:** 🟢 Use Every Day (after finishing any feature)
**Type:** Agent (hands off the task completely)
**Full agent:** `agents/code-reviewer.md`

---

## What It Does

Runs a **3-pass review** on your code changes:
1. **Design pass** — Are the abstractions right? Is the architecture sound?
2. **Code quality pass** — Readability, SRP, naming, complexity
3. **Test pass** — Are tests testing the right things? Any padding?

It comes back with findings grouped by severity. It's adversarial by design — it's looking for problems, not compliments.

---

## When to Use It

- After finishing any non-trivial feature
- Before pushing to a branch others will review
- When you feel uncertain about a design decision
- When the code got complicated and you want a fresh perspective

**As a solo dev**, this replaces the human code review you'd get on a team.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read agents/code-reviewer.md and review 
the changes in [file or folder path].

Context: I just implemented [brief description].
The main design decision was [decision and why].
```

**Claude Code:**
```
Use the code-reviewer agent on src/payments/
I added webhook handling for Stripe. Main decision: 
using idempotency keys to prevent duplicate processing.
```

**AGY:** "Review my code in..." or "Code review for..." triggers it.

---

## What Happens

The reviewer reads the files and runs 3 passes. You get a report like:

```
## Code Review — src/payments/webhook.py

### Pass 1: Design
✅ Idempotency key approach is correct for webhook handling
⚠️  HIGH: WebhookHandler is doing both validation AND processing
   — these should be separated (single responsibility)
   
### Pass 2: Code Quality  
⚠️  MEDIUM: process_event() is 87 lines — extract handle_payment_succeeded()
             and handle_payment_failed() as separate methods
ℹ️  LOW: Variable name `e` in except block should be `error` for clarity

### Pass 3: Tests
❌ HIGH: No test for duplicate webhook scenario (the case idempotency solves)
✅ test_webhook_signature_validation() correctly tests the boundary
⚠️  MEDIUM: test_payment_processing() mocks StripeClient but doesn't
            verify it was called with the right arguments
```

---

## What to Tell the Reviewer

Give it context it can't get from the code alone:

```
Context for reviewer:
- Files changed: src/payments/webhook.py, tests/test_webhook.py
- What I built: Stripe webhook handler with idempotency
- Key decision: Store processed event IDs in Redis (not DB) for speed
- I'm worried about: the error handling — is it robust enough?
- Constraints: Can't change the WebhookEvent model (shared with billing team)
```

The more context, the fewer false positives about "intentional" decisions.

---

## Acting on the Review

- **HIGH findings** → fix before pushing
- **MEDIUM findings** → fix or document why you won't
- **LOW/INFO findings** → your judgment; track as tech debt if skipping

You don't have to fix everything. But you should consciously decide on each finding.

---

## Time Investment

- Review runs: 2-5 minutes
- Fixes: depends on findings
- Saves: embarrassing PR comments, production bugs, design drift
