# Codebase Explorer Agent — Tutorial

**Tier:** 🔵 Situational (jumping into an unfamiliar codebase)
**Type:** Agent (hands off the task completely)
**Full agent:** `agents/codebase-explorer.md`

---

## What It Does

Systematically maps an unfamiliar codebase across 4 layers — shape, architecture, patterns, gotchas — and produces a **persistent orientation document** at `tasks/codebase-orientation.md`.

You (or any AI agent) reads that doc once and can work productively without re-exploring.

---

## When to Use It

- Starting work on a new project or repo you've never seen
- Coming back to a project after months away
- Taking over a codebase from someone else
- When AI agents keep making wrong assumptions about the codebase structure

**Skip it for:** codebases you already know well.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read agents/codebase-explorer.md and map this codebase. 
Produce the orientation document.
```

**Claude Code:**
```
Use the codebase-explorer agent to map this repo 
and create tasks/codebase-orientation.md
```

**AGY:** "Map this codebase", "explore and document this repo" triggers it.

---

## What It Does (4 Layers)

**Layer 1 — Shape (5-10 min):** What kind of project? How is it run? What are the entry points?

**Layer 2 — Architecture (10-20 min):** How is it layered? What talks to what? Where does data flow?

**Layer 3 — Patterns (10-15 min):** Error handling style, test approach, async patterns, conventions.

**Layer 4 — Gotchas (5-10 min):** Large files, warnings/hacks in comments, non-obvious dependencies.

---

## Sample Output

```markdown
# Codebase Orientation: payment-service

Generated: 2025-09-02

## What This Is
A Python FastAPI service handling payment processing for e-commerce. 
Integrates with Stripe and sends events to an internal message bus.
Run with: `uvicorn src.main:app --reload`
Test with: `pytest tests/`

## Top-Level Structure
src/
  api/          → FastAPI route handlers (thin — no business logic)
  domain/       → Pure business logic, no I/O (easy to test)
  infrastructure/ → Stripe client, DB models, message bus adapter
  core/         → Config, logging, shared utilities
tests/
  unit/         → Fast tests, no external dependencies
  integration/  → Requires running DB and Redis

## Architecture
Request → API layer → Domain layer → Infrastructure layer

Key data flows:
- Payment: POST /payments → PaymentService → StripeClient → EventBus
- Refund:  POST /refunds  → RefundService → StripeClient → DB

## Key Components

| Component | File | Responsibility |
|---|---|---|
| PaymentService | domain/payments.py | Orchestrates payment flow |
| StripeClient | infrastructure/stripe.py | All Stripe API calls |
| PaymentRepository | infrastructure/db.py | Payment record persistence |

## Patterns
- Error handling: domain raises domain exceptions; API layer maps to HTTP codes
- Testing: unit tests mock at infrastructure boundary, integration tests use real DB
- Config: all from env vars via src/core/config.py (Pydantic Settings)
- Async: all route handlers are async; domain is sync

## Gotchas
- infrastructure/stripe.py is 620 lines — complex retry/idempotency logic here
- PaymentService.process() must always be called with an idempotency key
- NEVER call StripeClient directly from route handlers — always go through domain
- WARNING in payments.py:L234: refund calculation has known edge case with partial captures

## Where to Start
| Task | Start here |
|---|---|
| Add a new payment method | domain/payments.py → infrastructure/stripe.py |
| Add a new API endpoint | api/routes/ → domain/ |
| Add tests | tests/unit/ — follow pattern in test_payment_service.py |
```

---

## After the Orientation

Tell future AI agents to read it first:

```
Before starting: read tasks/codebase-orientation.md for project context.
```

This prevents AI agents from making wrong assumptions about structure, patterns, or conventions.

---

## Time Investment

- Exploration: 30-45 minutes for a medium-sized codebase
- Saves: hours of re-exploration every time you (or an AI agent) starts a new task
