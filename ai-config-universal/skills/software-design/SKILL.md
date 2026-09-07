---
name: software-design
description: "Turn a spec, BRD, or rough feature request into a solid software design by forcing intermediate artifacts before implementation: problem model, discovery memo, layer stack, candidate decompositions, component contracts, and validation scenarios. Also covers implementing from a design (CONTRACT blocks, DESIGN.md sync) and reviewing designs for quality. Use when designing any non-trivial feature, when implementing from an existing design, or when reviewing design quality."
---

# Designing Features

## Mindset

Your job is complexity management. A good design finds the right boundaries so
that each part of the system can *forget* about the rest — not just "doesn't
need to know," but actively forgets. The component doesn't exist in its mental
model. That's the bar.

The reason you force intermediate artifacts — problem model, discovery memo,
layer stack — before naming any component is that jumping straight from
requirements to code produces designs shaped by whatever the author thought of
first, not by the actual forces in the problem. The artifacts slow you down
just enough to see the natural seams before you cut.

A design is the contracts: the guarantees, expectations, and refusals that let
everything else stop thinking about what's behind the interface. If the
contracts are explicit and findable, a new session can work on any component
without understanding the whole system.

---

## What are you doing?

This skill serves three phases. Find yours:

**Creating a design** — you have a spec, BRD, or feature request and need to
produce a design before implementation. Go to [Creating a Design](#creating-a-design).

**Implementing with a design** — a design exists (DESIGN.md, tasks/design.md,
or contracts in a sprint context). You're writing code and need to document
contracts, keep design artifacts in sync, and respect boundaries. Go to
[Implementing with a Design](#implementing-with-a-design).

**Reviewing a design** — you're checking whether a design is sound before
implementation, or whether the code matches the design after implementation. Go
to [Reviewing a Design](#reviewing-a-design).

---

## Creating a Design

### Read First

Before proposing anything new:

1. Read active task or sprint design docs if they exist
2. Read module-level `DESIGN.md` files near the affected code
3. Read the CONTRACT blocks of dependencies you expect to use — a CONTRACT
   block is a structured comment at the top of a source file that declares what
   the component guarantees, expects, refuses, and how it fails (see
   [Implementing with a Design](#implementing-with-a-design) for the full format)
4. Note reusable infrastructure, existing abstractions, and established patterns

Reuse existing good boundaries. Do not redesign the system from zero unless the
current structure is the problem.

### 1. Normalize the Problem

Turn the raw spec into a problem model before designing the solution.

**Technique:** Read the spec and highlight the nouns and verbs — those are the
essential complexity (the business problem itself). Cross out mentions of
specific databases, frameworks, or third-party tools — those are accidental
complexity (implementation choices). Build the nouns and verbs first.

Extract:
- user-visible outcomes
- actors and callers
- primary entities and state
- workflows and business rules
- invariants that must always hold
- external systems and integrations
- non-functional constraints
- unknowns and ambiguities

Separate requirements from implementation hints.

Bad: "Use Postgres and Redis" treated as architecture.
Good: "Needs durable storage and low-latency lookup" treated as requirement;
specific technologies remain negotiable unless explicitly mandated.

### 2. Run the Discovery Engine

If you cannot answer the questions below, you do not understand the problem
well enough to design it. Stop and get clarity before proceeding.

Before defining components, produce a short discovery memo using these lenses.
Each one reveals a different kind of boundary that a flat reading of the spec
will miss:

**Volatility map** — reveals where change will hit, so you can draw boundaries
that contain it instead of cutting across it.
- What is most likely to change in the next 12 months?
- Which boundaries would contain those changes?

**Core vs shell** — separates pure decision logic from side-effects (I/O,
persistence, transport, scheduling). Pure logic is easy to test, easy to
reason about, and never needs mocks. Side-effects belong in a shell that the
core doesn't know about.
- What is pure decision logic?
- What is only I/O, persistence, transport, scheduling, or integration?

**Failure domains** — reveals which pieces must be isolated so that one
failure doesn't cascade through the system.
- If each dependency goes offline, what must gracefully degrade?
- What is allowed to fail?
- How is the blast radius contained?

**Data lifecycle** — traces the primary entity through its phases of
transformation, revealing the natural pipeline stages.
- Trace the primary entity or state transition through the feature
- Identify the distinct phases of transformation

**State ownership** — reveals who owns mutation, which prevents the distributed
state bugs that are hardest to debug.
- Who owns mutation?
- What is persisted vs derived?
- Where do idempotency, caching, ordering, and concurrency control live?

### 3. Build the Layer Stack

Start with layers before components. Layering is one of the main decomposition
tools, not a cleanup step.

Each layer absorbs one kind of mess so the layer above can stop thinking about
it. A layer is justified only when it actually collapses complexity. If it just
forwards calls and renames methods, it is ceremony — delete it or merge it.

For each layer, state:
- what complexity it hides
- what API or model it exports upward
- what lower layers it depends on
- what it explicitly does not know about

Typical shape:

```text
Infrastructure / Adapters   -> raw I/O, transport, persistence, retries, serialization
Service / Adapter Layer     -> stable abstractions over external systems
Domain Layer                -> entities, invariants, domain operations
Application / Use Cases     -> workflows, orchestration, policy decisions
```

Bad layering: domain logic catches HTTP 429 and parses JSON payloads.
Good layering: a lower layer maps transport behavior into a domain-level error
before it crosses the boundary.

### 4. Generate and Evaluate Candidate Decompositions

Do not stop at the first reasonable cut. Before inventing from scratch, check
if a known architecture or design pattern already solves this shape of problem
(hexagonal, pipeline, event-driven, CQRS, repository+service, strategy, etc.).
If one fits, use it as a candidate and name which pattern.

Generate at least 2 candidates for moderate work and 3 for major design work.
One candidate must be layer-first. The others should use different lenses:
- data lifecycle or pipeline stages
- bounded contexts or domain concepts
- trust or privilege boundaries
- failure isolation

For each candidate, state:
- components — each with a single, clearly stated responsibility
- ownership — what data and behavior each component owns exclusively
- boundaries — the interfaces between components
- main dependency direction
- known pattern it draws from (if any)
- key trade-off

Apply the single responsibility principle at every level: each component,
module, package, and method should have one reason to change. If you cannot
state a component's single responsibility in one sentence, it is doing too
much.

Design components as focused, composable units with explicit interfaces.
Dependencies point inward toward domain logic. Components interact through
interfaces, not concrete implementations — this is what makes them swappable
and independently testable.

**Compare candidates on two axes:**

*Engineering quality* — how well does the design isolate change, hide
complexity, and protect boundaries? (Encapsulation, abstraction quality,
extensibility.)

*Simplicity* — is this the simplest design that solves the actual problem, or
does it build for hypothetical futures? (KISS, YAGNI.)

These axes pull against each other. Name the tension explicitly for each
candidate:

- If a design has strong boundaries but feels over-engineered, ask: is that
  structure solving a real problem within 12 months, or a hypothetical one?
- If a design is simple but has weak boundaries, ask: will that simplicity
  survive the first requirement change, or will it shatter?

The right design is usually not the most abstract one. It is the simplest one
whose boundaries will hold when the things that are likely to change actually
change.

**Recommend one candidate.** State:
- which candidate and why
- what it trades off
- why the rejected candidates lose — the specific scenario or force that makes
  them the wrong cut
- what would change your mind — the assumption that, if wrong, means you picked
  the wrong design

### 5. Define Component Contracts

Only after the decomposition is chosen, define contracts.

The design identifies what each component's contract *should* be. The actual
CONTRACT blocks in source files are written during implementation, when the
implementing agent has the concrete context to state what the code actually
guarantees.

For every component, specify:

**GUARANTEES**
- what callers can rely on — every guarantee must be specific and testable

Bad: "handles errors gracefully"
Good: "returns `TimeoutError` after `max_wait_ms` with no persisted side effects"

**EXPECTS**
- preconditions on inputs, state, and calling order

**FAILURE BEHAVIOR**
- deterministic behavior for each important failure mode

**DOES NOT**
- explicit refusals that keep the boundary hard

**KNOWN LIMITATIONS**
- work that belongs here but is deliberately not handled yet

**EMITS** (only when operationally important)
- logs, metrics, events, or traces that callers and operators should expect

Keep system-wide blast-radius reasoning in the design doc, not in every
component contract.

### 6. Surface Assumptions

List the assumptions the design depends on. For each:
- the assumption
- what invalidates it
- the fallback if it is wrong

Assumptions that are not written down will survive only in the current
conversation. That is not good enough.

### 7. Pressure-Test the Design

Walk the design through failure and change before treating it as complete.

**Scenario checks:**
- **happy path**: contracts compose cleanly end to end
- **outage test**: a dependency goes offline — does the failure stay contained?
- **change test**: a requirement changes or the client says "swap out that
  provider" — how many components must change? If more than one, the boundary
  leaked.
- **testability test**: can core business logic be tested with plain data, no
  mocks, no network?
- **deletion test**: can the feature be removed without surgery across unrelated
  code?

**Per-component checks:**
- **Blast radius**: if this component's contract changes, how many other files
  must update? The acceptable answer is as few as possible — ideally one.
- **Local reasoning**: can someone open this component's source file and
  understand what it does without reading the rest of the system? If no, the
  component knows too much.

If a scenario forces a component to reach into another component's internals,
the boundary is wrong.

### 8. Document the Design

The design artifact is a blueprint that a future agent can build from with no
additional context. At this stage you are *proposing* a design, not
implementing one. The design doc lives in `tasks/` — it does not go into the
module directory until implementation promotes it there.

**Where the design doc goes during creation:**

- If a spec file already exists (e.g. `tasks/user-notifications.spec.md`),
  name the design file to match: `tasks/user-notifications.design.md`
- If no spec exists, use: `tasks/YYYY-MM-DD-<topic>.design.md`

The design stays in `tasks/` as a proposed artifact. During implementation, the
implementing agent promotes it to `<module>/DESIGN.md` alongside the code. See
[Implementing with a Design](#implementing-with-a-design) for that process.

**What it contains:**

- problem model
- reusable existing pieces
- discovery memo
- layer stack
- candidate decompositions with trade-offs
- chosen decomposition and rationale
- component contracts (intended guarantees, expects, failure behavior, does not)
- assumptions and fallbacks
- validation scenarios
- open questions and out-of-scope items

---

## Implementing with a Design

### Mindset

A design exists. Your job is to build what it describes, document the contracts
in code as you go, and flag when reality diverges from the blueprint. The
design told you what each component *should* guarantee. Implementation is where
you discover what it *actually* guarantees and write that down.

The end result: every source file has a CONTRACT block that a future agent can
read without opening DESIGN.md, and DESIGN.md stays in sync with what was
actually built.

### Read the design and promote it

1. Check `tasks/` for the design doc (where designs live during creation)
2. Check `<module>/DESIGN.md` if a previous implementation already promoted one
3. Check the sprint's context.md for contracts and decisions

Understand the boundaries before writing code. Honor existing contracts —
respect their EXPECTS and rely only on their GUARANTEES.

### Promote the design doc

If the design is still in `tasks/`, promote it to its permanent home before or
alongside the first implementation commit:

```
project/
├── DESIGN.md                ← system-level: architecture, component relationships
├── auth/
│   ├── DESIGN.md            ← module-level: internal decomposition, interactions
│   ├── pool.py              ← CONTRACT block at top of file
│   └── ...
```

The design doc moves from `tasks/` (proposed) to `<module>/DESIGN.md`
(authoritative). Every module with 2+ components gets a DESIGN.md. The project
root gets a system-level one if the design spans multiple modules.

### Write CONTRACT blocks as you code

Every new source file gets a CONTRACT block at the top. You have the
implementation context — you know what the component actually guarantees. Write
the contract while that context is fresh. A separate agent writing it later
will produce weaker, less accurate guarantees.

Format:

```python
"""
CONTRACT: ConnectionPool (see auth/DESIGN.md for rationale)

GUARANTEES:
  - Never returns a closed or errored connection
  - All connections returned to pool or closed within timeout_ms
  - Thread-safe without external synchronization
  - At most max_connections open simultaneously

EXPECTS:
  - Caller calls release() when done
  - Config immutable after construction

FAILURE BEHAVIOR:
  - No connection within timeout_ms → TimeoutError, no side effects
  - Connection dies during use → transparent replacement
  - Pool shut down → PoolClosedError on all subsequent acquire()

DOES NOT:
  - Validate SQL or queries
  - Manage transactions
  - Retry failed queries

KNOWN LIMITATIONS:
  - No support for read replicas (returns primary only)
  - No connection draining on graceful shutdown (connections dropped)
"""
```

The CONTRACT block is a promise to future readers. Be specific. If a guarantee
is not testable, it is not a guarantee — it is a wish.

### Keep DESIGN.md in sync

If implementation reveals the design needs updating:
- Update the CONTRACT block in modified source files
- Update module-level DESIGN.md if internal structure changed
- Update system-level DESIGN.md if component relationships changed
- If a GUARANTEE changed, check all callers

A design doc that doesn't match the code actively misleads. Stale docs are
worse than no docs.

### Design to fit

When adding to an existing system:
- Follow existing patterns — don't introduce a different pattern without reason
- If the existing decomposition makes your feature awkward, that might mean
  boundaries need to move. Flag this as a decision, don't silently hack around
  it.

---

## Reviewing a Design

### Pre-implementation: Is the design sound?

Hand the design to a separate agent with no other context. Prompt:

> "It's 6 months from now and this system failed in production. Review
> the design — find the holes in correctness, robustness, and fault
> tolerance."

Do not bias the reviewer with specific concerns — let it find the problems
independently.

### Post-implementation: Is the code faithful to the design?

Check three things:

**1. DESIGN.md exists and is current.** Every module with 2+ components has a
DESIGN.md. It describes decomposition rationale and component relationships. It
matches the actual code — no references to renamed or deleted components, no
missing new ones.

**2. CONTRACT blocks exist and are consistent.** Every component's main source
file has a CONTRACT block with GUARANTEES, EXPECTS, FAILURE BEHAVIOR, DOES NOT.
The contracts are consistent with what DESIGN.md describes.

**3. Contracts are tested.** Every GUARANTEE has a test proving it holds. Every
EXPECTS violation has a test proving it's rejected. Every FAILURE BEHAVIOR has
a test triggering that failure.

Prompt for a documentation review agent:

> Read DESIGN.md in <modules>. Read CONTRACT blocks in every source file.
> Check: (1) Does DESIGN.md describe every component that exists in code?
> (2) Does every source file have a CONTRACT block? (3) Are the CONTRACT
> blocks consistent with DESIGN.md? (4) Is every GUARANTEE tested?
> Report gaps, inconsistencies, and untested guarantees.

### Design quality signals

**Healthy design looks like:**
- Small, focused files — each under 300-400 lines
- Each component has one clearly statable responsibility
- Interfaces between components, not concrete coupling
- Domain logic is pure — free of I/O, HTTP, SQL, file system
- Core logic testable with plain data, no mocks
- A likely requirement change stays within one component
- A component can be deleted without surgery elsewhere

**Sick design looks like:**

For the full catalog of design smells organized by coupling source, read
`{CONFIG_ROOT}/skills/software-design/references/design-smells.md`. Key signals at a glance:
- **Implementation leaking** — callers import types named after implementations
- **God classes** — one class doing everything, 10+ methods spanning unrelated concerns
- **Large files** — over 700 lines means multiple responsibilities tangled
- **Shotgun surgery** — one business rule change touches 5+ files
- **Infrastructure in domain** — domain code importing DB drivers, HTTP clients
- **Mock-heavy tests** — 10 mocks to test a business rule = design problem

### Periodic checks

**Contract compliance:** Does the implementation still honor every GUARANTEE?

**Boundary integrity:** Are components accessing each other's internals?

**Assumptions:** Are listed assumptions still valid?

---

## Heuristics

- Separate essential complexity (the business problem) from accidental complexity (the implementation mess)
- Push I/O and external wonkiness below the domain layer
- Single responsibility at every level — component, module, package, method
- Design to interfaces — components interact through contracts, not concrete implementations
- Prefer deep modules with simple interfaces over shallow wrappers
- Focused, composable components beat monoliths that "do everything"
- Make illegal states unrepresentable where possible
- If the core logic needs mocks to test basic decisions, the boundary is wrong
- If a likely change cuts across many components, the boundary is probably wrong
- If a layer cannot say what complexity it absorbs, it should not exist

---

## Output Shape

When asked to produce a design, present it in this order:

1. normalized problem model
2. discovery memo
3. proposed layer stack
4. candidate decompositions (with known patterns considered)
5. comparison on engineering quality vs simplicity
6. recommendation — chosen design with rationale and trade-offs
7. component contracts
8. assumptions
9. validation and failure analysis
10. open questions

Do not skip directly to component lists. Do not skip the comparison.
