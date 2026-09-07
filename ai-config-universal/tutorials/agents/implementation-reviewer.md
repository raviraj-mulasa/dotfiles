# Implementation Reviewer Agent — Tutorial

**Tier:** 🔵 Situational (after finishing a feature — did I miss anything?)
**Type:** Agent (hands off the task completely)
**Full agent:** `agents/implementation-reviewer.md`

---

## What It Does

A **completeness check** after you've finished a feature. A fresh-context agent reads your code and asks: "Is this actually done, or did the implementer miss something?"

The implementer (you) has blind spots — you know what you *intended* to do, so you may not notice what you *forgot*.

---

## When to Use It

- You finished a feature and want to sanity-check before declaring done
- You implemented something complex and worry you missed edge cases
- After a long coding session where you may have dropped threads
- Before the code-reviewer — catch completeness gaps first, then review quality

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read agents/implementation-reviewer.md and check 
the completeness of the rate limiting implementation.

Modified files: src/auth/middleware.py, src/auth/login.py
Feature: Redis-backed rate limiting on login endpoint (5 attempts/15min)
Also check: src/auth/reset.py (password reset should probably also be rate limited)
I'm uncertain about: error handling when Redis is unreachable
```

**Claude Code:**
```
Use the implementation-reviewer agent on the notification 
feature I just finished. Files: src/notifications/
Related: also check src/api/routes.py (new endpoints)
```

---

## What to Tell the Reviewer

**Give it pointers, not code:**

✅ Give:
- File paths of what you modified
- What the feature does (one sentence)
- Related components worth checking
- What you're uncertain about

❌ Don't give:
- Code snippets (let it read the files)
- Detailed explanations (let it form independent judgment)
- Your self-assessment ("I think I got everything")

The value comes from **fresh eyes** — don't bias the reviewer.

---

## Sample Output

```
## Implementation Review — Rate Limiting

### Completeness Assessment

✅ Core feature: Rate limiting middleware reads/writes Redis correctly
✅ Login route: Middleware applied in correct order
✅ 429 response: Correct status code with Retry-After header
✅ Tests: test_login_blocked_after_5_attempts() covers the happy path

### Gaps Found

⚠️  HIGH: Password reset endpoint (POST /auth/reset-request) has no rate 
    limiting — this is the more critical attack surface since it reveals 
    whether an email is registered. Recommend same treatment.

⚠️  MEDIUM: No test for Redis being unreachable. Your code has a try/except 
    that falls back to allowing the request — but this path is untested. 
    If the except clause has a bug, you'd have a silent failure.

⚠️  MEDIUM: Rate limit counter increments on ALL attempts, including valid 
    logins. A user with the right password but transient network issues 
    could lock themselves out. Consider only incrementing on failure.

ℹ️  INFO: The RATE_LIMIT_WINDOW_SECONDS env var is documented in the code 
    but not in the README or .env.example. Future deployers won't know it exists.

### Verdict

CONDITIONAL — core feature complete; address HIGH gap before shipping.
```

---

## Difference from Code Reviewer

| Implementation Reviewer | Code Reviewer |
|---|---|
| "Did you build everything?" | "Did you build it well?" |
| Completeness gaps | Code quality, SRP, naming |
| Run first | Run second |
| Fresh context — give minimal info | Give architectural context |

---

## Time Investment

- Review runs: 2-4 minutes
- Saves: shipping features with holes, discovering gaps after users hit them
