---
name: writing-specs
description: Create, extract, and maintain functional specifications — the source of truth for AI-driven development. Use when defining a new feature, retrofitting specs onto existing code, updating specs after behavior changes, or when any agent asks "what should this do?" Also use when the user mentions specs, functional requirements, source of truth, or wants to document what a system does (not how it's built). This is the foundation skill — specs feed every other workflow (design, implementation, testing, QA).
---

# Functional Specifications

You're writing the source of truth. Not documentation — the contract that every agent (builder, tester, architect, QA) works from. If the spec is wrong, everything downstream is wrong. If the spec is incomplete, agents guess, and guesses compound.

The goal: lose the entire codebase, hand an agent the spec tree, and they rebuild the system with identical external behavior in any technology. That's the bar.

## Before anything

Every project with specs has a `docs/specs/AGENT.md` (or `docs/specs/CLAUDE.md`) that defines the format, the consumer lens, file organization rules, and the spec/implementation boundary. **Read it before writing or modifying any spec.** If the project doesn't have one yet, create it.

Also read the project's `docs/specs/README.md` for the spec index and section convention.

## Three modes

### 1. Create — from requirements

When the user describes what they want, or a feature request exists, or you're specifying a new system.

**Process:**
1. Understand the domain. What is this system? Who consumes it? What are the external interfaces?
2. Decompose into a spec tree. Start at the top — what are the major functional areas? Each becomes a spec file or a section in a parent spec.
3. For each node in the tree, write the spec from the consumer's perspective. What do they see, send, receive, experience?
4. Cross-link. Parent specs summarize children and link down. Child specs reference siblings where behavior depends on them.
5. Update the README.md index.

**The decomposition question:** At each level, ask "could an agent work on this piece independently?" If yes — it's the right granularity for a spec file. If they'd need to read three other specs to understand this one — it's either too granular or missing cross-references.

### 2. Extract — from existing code

When a codebase exists without specs and you need to retrofit the source of truth.

**Process:**
1. Map the external interfaces. What does the user see? What do clients send and receive? What events are emitted? Don't read internals yet — start from the outside.
2. Read the code to discover behaviors that aren't obvious from the interface. Edge cases, error handling, state transitions, defaults, implicit contracts.
3. Write the spec describing what the system DOES (its current behavior), not what you think it SHOULD do. Extraction is observation, not design.
4. Flag discrepancies. If the code does something that seems wrong, note it in the spec as `[REVIEW: behavior X seems unintentional — confirm or update]`. Don't silently "fix" the spec.
5. Build the tree top-down even though you're reading bottom-up. Start with the overview spec, decompose into components/endpoints/stages.

**The trap:** When extracting, you'll be tempted to describe implementation. "This function calls X, which returns Y" is implementation. "When the user requests Z, the system returns Y within 2 seconds" is specification. Always translate from code mechanics to consumer-observable behavior.

### 3. Maintain — after behavior changes

When implementation changes what the system does, the spec must update first (or simultaneously).

**Process:**
1. Identify which spec files are affected by the change.
2. Update requirements, states, edge cases, or data contracts.
3. If new functionality doesn't fit an existing spec, create a new node in the tree and link it from the parent.
4. Update the README.md index if files were added or removed.
5. Check that cross-references between specs are still accurate.

## Decomposition principles

The spec tree mirrors the consumer's mental model, not the codebase structure.

**Split when:** a section grows past ~80-100 lines of requirements, or when an independent team of agents could work on it without needing the rest of the parent.

**Keep inline when:** the component is simple (20-30 lines of spec) and only meaningful in the context of its parent.

**Name files for what they specify, not where they live in code.** `session-detail.md` not `SessionDetailPage.tsx.spec.md`. The spec is technology-agnostic.

For domain-specific decomposition patterns, read the relevant reference if available:
- `references/ui-specs.md` — pages, components, data flows
- `references/api-specs.md` — endpoints, data models, error contracts
- `references/pipeline-specs.md` — stages, event flows, processing guarantees

## Writing requirements that work

Every requirement is a testable assertion about what the consumer observes. If you can't write a test for it, it's not a requirement.

**Numbering:** R1, R2, ... for top-level. R1.1, R1.2 for sub-requirements. This lets tests, QA plans, and verification criteria reference specific behaviors precisely.

**Precision over brevity.** A requirement that's too specific is easier to relax than one that's too vague is to tighten. When in doubt, be concrete:

```
Too vague:   R3 — Errors are handled gracefully.
Right level: R3 — When the API returns 5xx, the page shows an error banner
             with the message "Something went wrong. Retry?" and a retry
             button. Clicking retry re-fetches. Three consecutive failures
             show "Service unavailable" with no retry option.
```

**Dependencies between specs.** When one spec's behavior depends on another's output, reference it precisely: "R2.1 — Turn grouping uses `turn_index` from the threading spec (see `pipeline/threading.md` R4)." This creates a traceable dependency chain.

## Validation — mandatory, separate agent

Self-review doesn't work. The agent that wrote the spec is blind to its own assumptions. After writing or updating any spec, you MUST spawn a separate validation agent.

**How:** Spawn a fast-worker agent with this prompt:

```
Validate this spec file: <path-to-spec>

Check for:
1. Every requirement is testable (can you write a test for it?)
2. No vague guarantees ("handled gracefully" without defining "gracefully")
3. All states covered (success, error, loading, empty)
4. All actor interactions defined
5. Dependencies on other specs are explicitly cross-referenced
6. No implementation details (code mechanics) in the spec

Report PASS/FAIL for each item with a one-line explanation on failures. End with a summary verdict.
```

**On failures:** Fix the issues yourself, then re-run validation. The spec is not done until the validator reports all items passing.

**Why a separate agent:** The writer has context the reader won't. When you write "errors are handled appropriately," you know what you mean — but the validator (and every future agent) doesn't. The validator catches exactly the gaps that matter: where your intent didn't make it onto the page.
