# Sprint Skill — Tutorial

**Tier:** 🔵 Situational (decomposing a large feature into parallel tasks)
**Type:** Skill (orchestration — you direct agents)
**Full skill:** `skills/sprint/SKILL.md`

---

## What It Does

Breaks a large feature into **bricks** — small, independently verifiable units of work — then orchestrates parallel AI agents to execute them in waves, with evidence gates between waves.

Think of it as a structured project manager for multi-agent AI work.

---

## When to Use It as a Solo Dev

**Use it when:**
- Feature is large enough to take multiple coding sessions
- You want to work in focused parallel streams (frontend + backend simultaneously)
- You want formal acceptance criteria per task and a progress log
- You've been burned by "I thought it was done" before

**Skip it for:** features you can finish in a single focused session.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/sprint/SKILL.md and help me decompose 
the notification system feature into a sprint.

Feature: email + in-app notifications with user preferences.
Spec: tasks/2025-09-02-notifications.spec.md
```

**Claude Code:**
```
Use the sprint skill to plan the OAuth implementation.
```

---

## The Core Concept: Bricks

A **brick** is not a task — it's a building block with a verifiable guarantee:

```json
{
  "id": "B01",
  "name": "NotificationPreference model",
  "responsibility": "Store per-user, per-type notification settings",
  "guarantees_tested": "test_preference_defaults_to_enabled() passes",
  "files": ["src/notifications/models.py", "tests/test_notification_model.py"],
  "depends_on": [],
  "status": "pending"
}
```

The `guarantees_tested` field is the key — it forces you to define what "done" means **before** the agent builds it.

---

## Wave Structure

Bricks are grouped into waves. Wave 2 doesn't start until Wave 1 passes its evidence gate:

```
Wave 1 (Foundation — no dependencies):
  B01: NotificationPreference model
  B02: NotificationChannel enum
  → Gate: both unit tests pass

Wave 2 (Core logic — depends on Wave 1):
  B03: NotificationService.send()
  B04: PreferenceChecker.should_notify()
  → Gate: integration test for send-with-preferences passes

Wave 3 (Delivery — depends on Wave 2):
  B05: EmailAdapter
  B06: InAppAdapter
  → Gate: end-to-end test passes

Wave 4 (API — depends on Wave 2):
  B07: GET/PUT /preferences endpoint
  → Gate: API test passes
```

---

## What You Get

A `tasks/sprint-name.tasks.json` file tracking all bricks + status, and a `progress.md` audit log.

```
tasks/
  2025-09-02-notifications.tasks.json   ← brick definitions + status
  2025-09-02-notifications.progress.md  ← evidence log (append-only)
  2025-09-02-notifications.objective.md ← what we're building and why
```

---

## Solo Dev Shortcut

You don't have to spawn actual parallel agents. The sprint structure still helps you:
- Know exactly what to build next (`ready` command shows unblocked bricks)
- Know when something is truly done (guarantees tested, not just "seems right")
- Have a progress log you can resume from if interrupted

---

## Time Investment

- Sprint planning: 30-60 minutes for a medium feature
- Saves: mid-feature confusion, incomplete features that "almost work", lost progress on resumption
