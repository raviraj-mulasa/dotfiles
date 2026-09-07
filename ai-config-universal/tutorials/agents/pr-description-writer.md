# PR Description Writer Agent — Tutorial

**Tier:** 🟢 Use Every Day (before every PR)
**Type:** Agent (hands off the task completely)
**Full agent:** `agents/pr-description-writer.md`

---

## What It Does

Writes a **structured pull request description** from your diff and context — the kind that makes reviewers' jobs easy and speeds up merges.

---

## When to Use It

- Every time you open a pull request
- When you're about to push to a shared branch
- When you want to document what changed and why before you forget

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read agents/pr-description-writer.md and write 
a PR description for my current changes.

Context: I added rate limiting to the login endpoint to 
prevent brute force attacks. Linked issue: #142.
```

**Claude Code:**
```
Use the pr-description-writer agent.
I implemented Stripe webhook handling — issue #87.
```

**AGY:** "Write a PR description" or "PR description for..." triggers it.

---

## What Happens

The agent reads `git diff main...HEAD` and your context, then produces:

```markdown
## What

Adds Redis-backed rate limiting to `POST /auth/login` to prevent 
brute-force attacks. After 5 failed attempts per IP within 15 minutes, 
the endpoint returns 429 with a `Retry-After` header.

## Why

We had no protection against password stuffing attacks. Closes #142.

## Changes

- Added `RateLimitMiddleware` in `src/auth/middleware.py` — checks 
  Redis counter per IP before passing request to login handler
- Login route now applies middleware before auth logic
- Added `RATE_LIMIT_MAX_ATTEMPTS` and `RATE_LIMIT_WINDOW_SECONDS` 
  env vars (defaults: 5, 900)
- 4 new tests: happy path, limit hit, counter reset, Redis timeout fallback

## How to Test

1. `pytest tests/test_login.py` — all 12 tests should pass
2. Run the app locally, call `POST /auth/login` 6 times with wrong password
3. Verify the 6th call returns 429 with `Retry-After: 900`
4. Wait for window to expire (or set `RATE_LIMIT_WINDOW_SECONDS=5`) — 
   verify login works again

## Notes for Reviewers

- Redis timeout falls back to allowing the request (fail open) — this 
  is intentional. Locking out users because Redis is down is worse than 
  the alternative. We can revisit if this is controversial.
- Rate limiting is per-IP only, not per-username. Username-based limiting 
  would allow denial-of-service on valid accounts.

## Checklist
- [x] Tests added for new behavior
- [x] No secrets in diff
- [ ] Breaking changes: none
- [ ] Migration needed: add RATE_LIMIT_* env vars to deployment config
```

---

## What to Give the Agent

Minimum: just run it — it reads the diff.

Better — add context it can't get from the diff:
```
Context:
- This closes issue #142
- Key decision: fail open on Redis timeout (we discussed in slack)
- Reviewers should pay attention to: the middleware ordering in routes.py
```

---

## Why This Matters

A bad PR description forces every reviewer to read the entire diff to understand what they're reviewing. A good one guides them straight to what matters.

**As a solo dev**, this also serves as your own documentation — you'll thank yourself when you're bisecting a regression in 3 months.

---

## Time Investment

- Agent runs: 1-2 minutes
- You review and adjust: 2-3 minutes
- Saves: reviewer friction, back-and-forth questions, merge delays
