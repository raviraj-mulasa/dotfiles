---
name: debugging
description: Systematic debugging through hypothesis → observation → confirmation → fix. Use when investigating bugs, unexpected behavior, or when explanations are unverified assumptions. Triggers on 'debug', 'investigate', 'why is this happening', 'root cause', or any situation where the cause is unknown.
---

# Debugging — Stop Guessing, Start Proving

You're here because something isn't working. You're about to explain why.

You don't know why. You have guesses. That's all they are.

Code surprises you. External interactions, race conditions, ordering assumptions, stale state, multiple systems interacting — reading code tells you what *should* happen. Only runtime tells you what *does* happen.

Run the four phases below in order. Do not skip phases. Do not jump to Phase 4 without evidence from Phase 3.

---

## Phase 1: Formulate Hypotheses (not conclusions)

List every plausible explanation. Not just the one that seems most likely — ALL of them.

For each hypothesis:

- **H1**: [one-sentence description]
  - What evidence would CONFIRM this?
  - What evidence would REFUTE this?
  - How do I observe the runtime behavior to check?

Minimum 2 hypotheses. If you can only think of one, you have a blind spot — look harder.

Do NOT pick a winner yet. Present all hypotheses to the user before proceeding.

---

## Phase 2: Design Observations

For each hypothesis, design a way to check it against actual runtime behavior:

| Method | When to use |
|--------|-------------|
| `console.log` / `tracing::debug!` | Trace execution paths, inspect data at decision points |
| Network tab / SSE stream | Verify what the server actually sends vs what you assume |
| Browser DevTools | Inspect rendered DOM, CSS computed values, React state |
| API calls (curl, fetch) | Hit endpoints directly, see raw responses |
| Log files on disk | Check what was actually written vs what should have been |
| Screenshots / screen recordings | See what the user actually sees |

Observe at the BOUNDARY where you think the bug is. If you think the data is wrong, log the data. If you think the render is wrong, inspect the DOM. If you think the API is wrong, read the response.

Add the minimal instrumentation needed. Build, deploy, reproduce. Collect evidence.

---

## Phase 3: Confirm or Refute

Run the observations. For each hypothesis:

- **CONFIRMED**: evidence matches prediction — move to Phase 4
- **REFUTED**: evidence contradicts prediction — cross it off, revise
- **INCONCLUSIVE**: need different or better observation — design a new one

If ALL hypotheses are refuted, return to Phase 1 with the new evidence. The evidence itself narrows the search space.

Show the user the evidence. Do not just say "I confirmed H2" — show the log output, the network response, the screenshot that proves it.

---

## Phase 4: Fix (only after confirmation)

Now — and only now — design the fix. Do not jump straight to code:

1. **Root cause**: What is the root cause, not just the symptom?
2. **Ownership**: Does the fix belong here, or is the real problem upstream?
3. **Alternatives**: What are at least 2 ways to fix this? What are the tradeoffs?
4. **Blast radius**: What else could this change affect?

Present the fix approach to the user before implementing. Then implement. Then verify the fix with the SAME observation method from Phase 2 — prove it works, do not assume it works.

---

## Why This Feels Slow (It Isn't)

The training wants you to pick the first plausible explanation, ship a fix immediately, and declare victory.

Every time you do this without evidence, you are gambling. Sometimes you'll be right. When you're wrong, you waste time, burn trust, and often make things worse.

The slower path — hypothesize, observe, confirm, fix — is faster in practice because you fix the right thing the first time.

---

## Quick Reference

```
1. STOP — you don't know yet
2. LIST hypotheses (minimum 2)
3. DESIGN observations for each
4. RUN observations, collect evidence
5. SHOW evidence to user
6. Only then: DESIGN the fix (consider alternatives)
7. IMPLEMENT and VERIFY with same observation method
```
