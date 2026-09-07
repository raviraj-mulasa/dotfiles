# Software Design Skill — Tutorial

**Tier:** 🟡 Use Weekly (before designing any non-trivial component)
**Type:** Skill (you stay in the driver's seat)
**Full skill:** `skills/software-design/SKILL.md`

---

## What It Does

Takes a feature requirement and produces a **complete design** before you write any code:
- Normalizes the problem (separates requirements from implementation hints)
- Runs a discovery engine (volatility, failure domains, data lifecycle)
- Generates 2-3 candidate architectures with tradeoffs
- Recommends one and explains why
- Defines component contracts (GUARANTEES, EXPECTS, FAILURE BEHAVIOR)

Output: `tasks/YYYY-MM-DD-feature.design.md`

---

## When to Use It

- New component, service, or module (not a single function)
- Changing how multiple components interact
- Adding a feature that touches the data model
- Any time you catch yourself thinking "I'll figure it out as I go" on something non-trivial

**Skip it for:** adding a single API endpoint to an existing pattern, UI-only changes, bug fixes.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/software-design/SKILL.md and design 
the notification system for this app. Requirements: 
[paste requirements or spec]
```

**Claude Code:**
```
Use the software-design skill to design the job queue system.
Requirements: process background jobs reliably, retry on failure,
max 3 retries, dead letter queue for permanently failed jobs.
```

**AGY:** "Design a..." or "help me architect..." triggers it.

---

## What Happens

**Phase 1 — Discovery memo:**
```
Volatility map:
- Most likely to change: notification channels (email now, push later, SMS later)
- Stable: the decision logic of WHEN to notify

Core vs shell:
- Pure logic: "should this user get this notification?" → Domain layer
- I/O: sending email, storing notification record → Shell layer

Failure domains:
- Email provider going down must not block app functionality
- Notification delivery can be async and eventually consistent
```

**Phase 2 — Candidate designs:**
```
Candidate A (Layer-first): 
  NotificationService → ChannelAdapter → EmailProvider
  Trade-off: Clean but may over-engineer for MVP

Candidate B (Event-driven):
  Events → NotificationWorker → Channels
  Trade-off: Scales well but adds queue complexity

Recommendation: Candidate A for now — swap to B when you have 
multiple channel types. The ChannelAdapter interface makes this 
migration straightforward.
```

**Phase 3 — Contracts:**
```
CONTRACT: NotificationService

GUARANTEES:
  - Notification attempt logged within 100ms of call
  - Email delivery attempted at most once per notification ID
  
EXPECTS:
  - Caller provides valid user ID and notification type
  
FAILURE BEHAVIOR:
  - Email provider unavailable → log failure, return NotificationResult(sent=False)
  - Unknown notification type → raise ValueError immediately
  
DOES NOT:
  - Guarantee delivery (email may bounce)
  - Retry failed sends (caller's responsibility)
```

---

## The Key Value

Without this skill: you pick the first design that comes to mind, discover its problems 3 weeks later, and refactor.

With this skill: you evaluate alternatives explicitly before committing, and you have written contracts that tell future-you (and AI agents) exactly what each component promises.

---

## Time Investment

- Design session: 30-60 minutes for a medium component
- Saves: 4-8 hours of refactoring when the first design doesn't hold up
