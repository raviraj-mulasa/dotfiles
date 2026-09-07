---
name: code-quality
description: Review and improve code quality — architecture review, simplification, SRP analysis, and implementation completeness checks. Use when reviewing code changes, simplifying complex code, analyzing component responsibilities, or verifying a feature is fully implemented. Triggers on 'review', 'simplify', 'clean up', 'SRP', 'is this complete', or after finishing implementation.
---

# Code Quality

Review and improve code quality from multiple angles.

---

## Pragmatic Review

Evaluate code and design decisions against pragmatic principles. The goal: **obvious, maintainable code that ships** — not clever code or ivory-tower purity.

### Core Values (Priority Order)

1. **Clarity over cleverness** — Code should be easy to reason about
2. **Shipping over perfection** — But shipping maintainable work, not hacks
3. **Simplicity over flexibility** — Solve today's problems, refactor when needed
4. **Obviousness over abstraction** — Design feels natural and matches the problem's shape
5. **Domain-focused over implementation-leaking** — Abstractions describe **what**, not **how**
6. **Real gains over ceremony** — Every file, interface, and layer must justify its existence

### The Design "Click" Test

Does this design click?
- Feels obvious, natural, easy to explain
- Matches the problem's natural shape
- Someone could understand it in 6 months without you
- Changes are localized and predictable
- Tests don't require heroic setup

If NO — either too clever, too scattered, or too coupled.

### Invoking a Review

Code review is done by a separate agent with fresh context — never inline. The reviewer reads the design, code quality, and test skills as its methodology.

Spawn the code-reviewer agent. Brief it with:
- What files changed and why
- Any design context (decisions, constraints, rejected alternatives)
- Specific concerns you want checked

The reviewer runs three passes (design, code, tests) and reports findings. See `{CONFIG_ROOT}/agents/code-reviewer.md` for the full review protocol.

### Quick Reference

| Question | Answer |
|---|---|
| Should I split this class? | No if "lots of related ops" or creates <20 line files. Yes if doing unrelated things. |
| Should I create an interface? | No if "just in case". Yes if 2+ implementations exist NOW or callers shouldn't know the implementation. |
| Too many files/layers? | Ask: what does each layer ADD, not just delegate? "More proper" → remove. "Separates concerns" → keep. |
| Doing too much? | Can't explain in one sentence → split. Can't share data across methods → split. Lots of cohesive code → keep. |
| Do callers know too much? | If callers import implementation types (Sqlite*, Redis*, Http*), the abstraction is missing. Flag it. |

**Swap Test:** If I need to change an implementation detail (database, external service), how many files do I touch? If more than one module → the implementation leaked through the boundary.

---

## Simplification

A behavior-preserving clarity pass. Not a rewrite. Not a refactor. Making code clearer without changing what it does.

### The One Rule

**Never change what the code does.** Every input produces the same output. Every side effect fires the same way. Every error propagates the same path. If you're unsure whether a change preserves behavior, don't make it.

### Find the Changed Code

1. Run `git diff --name-only` for unstaged changes
2. Run `git diff --cached --name-only` for staged changes
3. If nothing is dirty, run `git diff HEAD~1 --name-only` for the last commit
4. If `$ARGUMENTS` specifies files or scope, use that instead

Read every changed file. Understand it fully before touching anything.

### What to Simplify

**Unnecessary complexity:**
- Nested conditionals that could be early returns or guard clauses
- Boolean expressions that could be simplified (`if x == True` → `if x`)
- Redundant variables assigned and immediately returned
- Double negations (`not (not x and not y)` → `x or y`)
- Overly defensive code — null checks on values that can't be null

**Redundancy:**
- Dead code — unreachable branches, unused imports, commented-out blocks
- Duplicate logic appearing in multiple places within the changed files
- Wrapper functions that just delegate with the same signature
- Abstractions with only one use that don't clarify intent

**Unclear naming:**
- Variables named `data`, `result`, `temp`, `val` when a domain term exists
- Functions whose names don't describe what they actually do
- Inconsistent naming within the same file

**Structural noise:**
- Overly granular functions that fragment a simple, linear operation
- Classes that exist for one method (where a function would do)
- Unnecessary intermediate data structures
- Verbose patterns where the language offers a clearer idiom

**Comments that lie or add nothing:**
- Comments restating the code (`# increment counter` above `counter += 1`)
- Stale comments describing what the code *used to* do
- Addressed TODO/FIXME that were never removed

### What NOT to Simplify

- **Working abstractions that aid understanding.** A well-named helper function is simpler even if inlining it saves lines.
- **Error handling.** Don't remove catches, guards, or validation just because the happy path works.
- **Intentional verbosity.** A clear `if/elif/else` chain sometimes beats clever dictionary dispatch.
- **Code outside the change scope.** Unless `$ARGUMENTS` says otherwise, stay in recently modified files.
- **Tests.** Test verbosity is often intentional — it makes failures easier to diagnose.

### 5-Step Process

1. **Read first, completely.** Read every changed file end to end. Understand the flow, conventions, patterns already in use.
2. **Respect the project's voice.** Match naming patterns, indentation, comment density — whatever's already there. Consistency is its own form of simplicity.
3. **Make changes that pass the "obviously better" test.** If a change requires explanation for why it's simpler, it probably isn't.
4. **Prefer small, independent changes.** Don't restructure a whole function at once. Each edit should be self-contained, easy to review, easy to revert.
5. **Show what you changed and why.** Brief summary grouped by type (removed dead code, simplified conditionals, improved naming). The diff is the real documentation.

### The Balance

Clear and concise, but never cryptic.

- Replacing 5 readable lines with 1 dense line → compression, not simplification
- Replacing 1 dense line with 5 readable lines → might be simplification
- If a pattern is "clever," it's probably not simple
- If you have to think about whether a change is clearer, it's probably not worth making

When done, list changes made grouped by category. If you made no changes, say so — sometimes code is already as simple as it should be. That's a valid outcome.

---

## SRP Redesign

Clean-slate component analysis. Redesign a target following strict Single Responsibility Principle and KISS principles.

### Analysis

First, determine: does the current implementation violate SRP? Analyze the existing code and identify all different responsibilities and concerns mixed together.

### Redesign Criteria

1. Each component has exactly ONE responsibility
2. Clean abstraction layers — each layer hides complexity from layers above
3. No component knows about other components' internals
4. Simple, focused interfaces
5. Zero backward compatibility — this is clean-slate design

### For Each Proposed Component

Answer:
- What is its SINGLE responsibility? (one sentence)
- What should it NOT know about?
- How would you test it in isolation?

### Implementation Plan Template

```
Components:
- [ComponentName]: [single responsibility, one sentence]
  - Knows: [only its own domain]
  - Does NOT know: [other components, implementation details]
  - Test in isolation by: [approach]

Data flow:
- [Input] → [ComponentA] → [output] → [ComponentB] → [output]

File structure:
- [file]: [what it contains]

Testing strategy:
- [layer]: [how to test without the layers above/below]
```

### Validation

Ask: "If I need to change [concern X], how many components do I touch?"

The answer should be: **exactly one.**

If the answer is more than one, the responsibilities aren't cleanly separated yet.

---

## Implementation Completeness

A fresh-agent review for blind spots after finishing a feature. When you're close to the work, you have blind spots. You know what you *intended* to do, so you might not notice what you *forgot*. This workflow is that question.

### How to Use This

**Pass (cheap):**
- File paths you modified
- Function/class names you changed
- The feature or API this is part of
- Related components worth checking
- What you were trying to accomplish (one sentence)
- Areas you're uncertain about

**Never include (expensive):**
- Code snippets or diffs
- File contents
- Detailed explanations of what the code does

Point, don't paste. Tell the agent where to look. Let it do the reading and verification.

### Invoke the Agent

```
🤖 implementation-reviewer — "Review [feature name]"

Implemented [brief description].

Modified:
- path/to/file.py (function_name)
- path/to/config.py (new setting)

Affects: [the API/feature this is part of]

Also check: [related component], [other API that uses this]
```

### Decision Chain (Critical for Accurate Reviews)

Without the decision chain, the reviewer can only check code quality — not whether the code matches what was agreed. It will flag intentional decisions as bugs.

**If a sprint session exists:**

Check sprint task files for:
- brick status and progress
- decisions (why things were built this way, not just what)
- session objective and current state

Include this context in the reviewer prompt. It gives the reviewer decisions (why things were built this way), brick list (what was attempted, what passed, what was pivoted), and session status (objective and current state).

**If no sprint session exists**, discover task files manually:

```bash
ls tasks/*.md
```

Include file paths in the reviewer prompt alongside source file paths. The reviewer needs the design doc and handoff to understand WHY decisions were made.
