# Brainstorming Skill — Tutorial

**Tier:** 🔵 Situational (when stuck on a design decision)
**Type:** Skill (interactive — Socratic dialogue)
**Full skill:** `skills/brainstorming/SKILL.md`

---

## What It Does

Acts as a senior engineer at the whiteboard — pushes back, asks hard questions, maps the option space, and helps you commit to a decision with clarity about tradeoffs.

Not a yes-machine. Designed to challenge your assumptions.

---

## When to Use It

- You're choosing between two approaches and can't decide
- Something feels off about a design but you can't name it
- You're about to build something and want to think it through first
- You're solving a problem by adding complexity — and want to check if that's right

**Trigger phrases:** "Should I...", "I'm thinking about...", "What's the best way to...", "I can't decide between..."

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/brainstorming/SKILL.md and brainstorm 
with me: should I use a job queue or process webhooks synchronously?
```

**Claude Code / AGY:**
```
Use the brainstorming skill. I'm deciding whether to cache 
API responses in Redis or always fetch live. Help me think through it.
```

---

## What Happens

The AI maps the option space, asks questions that prune it, and commits with a named decision:

```
Let me map the tree before recommending anything.

Option A (always live): Simplest. But what's your p95 response time 
to that API? And what happens to your app if it goes down?

Option B (cache in Redis): Reduces latency, adds resilience. 
But how stale is too stale for your use case? 
And who invalidates the cache when data changes?

Option C (cache at the HTTP layer with ETags): Might be free 
if the API supports it. Have you checked?

My lean right now: Option A until you hit a real performance 
problem. Premature caching is a common source of stale-data bugs.

What's your API's uptime SLA? That changes my answer significantly.
```

---

## The Commit Format

When a decision is reached:

```
Considered: always-live, Redis cache, HTTP cache
Chosen: always-live (for now)
Why: no measured latency problem yet; caching adds invalidation complexity
Limitations: won't work if API goes down or if p95 > 500ms
Fine because: API is internal, 99.9% SLA, measured p95 is 120ms
Reversal: revisit if latency > 300ms or if API availability < 99%
```

This gets saved to a decisions log — so future-you knows why the decision was made and when to revisit it.

---

## Time Investment

- Session: 10-20 minutes
- Saves: building the wrong thing, making a decision you can't articulate later
