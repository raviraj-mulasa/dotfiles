# Debugging Skill Tutorial

**Tier:** 🟢 Use Every Day
**Type:** Skill (you stay in the driver's seat)
**Full skill:** `skills/debugging/SKILL.md`

---

## What It Does

Forces you through a 4-phase process: **hypothesize → observe → confirm → fix**.
Stops you from jumping to a fix before you know the actual cause.

---

## When to Use It

- Something is broken and you don't know exactly why
- You have a hunch but haven't proven it
- You've already tried one fix and it didn't work
- The bug is intermittent or environment-specific

**Don't use it for:** obvious typos, missing imports, clear syntax errors — just fix those directly.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/debugging/SKILL.md and apply the debugging 
workflow to this error:

[paste error message or describe the symptom]
```

**Claude Code:**
```
Use the debugging skill on this issue:
[describe the symptom]
```

**AGY:** Just describe the problem — "debug", "why is this happening", "root cause" triggers it automatically.

---

## What Happens

The AI will:
1. Ask you to list **all** hypotheses — not just your favourite one (minimum 2)
2. Design a specific observation for each hypothesis
3. Have you run the observation and share results
4. Only then propose a fix — with alternatives

It will **refuse to jump to a fix** without evidence. That's the point.

---

## Real Example

**You:**
```
Use the debugging skill. My app crashes on startup in production 
but works fine locally. Error: "Connection refused to Redis".
```

**AI response (Phase 1 — Hypotheses):**
```
Before we fix anything, let's list all plausible hypotheses:

H1: Redis is not running in the production environment
  - Confirm: ssh prod, run `redis-cli ping`
  - Refute: would see different error message

H2: Redis URL is wrong in prod config (wrong host/port)
  - Confirm: check $REDIS_URL env var in prod
  - Refute: H1 would catch this first

H3: Firewall is blocking Redis port 6379
  - Confirm: `telnet redis-host 6379` from prod server
  - Refute: redis-cli would give a different error

Which of these can you check right now?
```

**You share results → AI designs more observations → You confirm → AI proposes fix with alternatives.**

---

## Common Mistake

❌ Saying "I think it's H2, let's fix that" — the skill will push back and ask for evidence first.

✅ Actually run the observation, share the output, let the evidence speak.

---

## Time Investment

- Simple bugs: 10-15 minutes
- Complex/intermittent bugs: 30-60 minutes
- Saves: hours of trying random fixes that don't work
