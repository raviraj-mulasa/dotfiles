---
name: grill-me
description: "Interrogation session that turns fuzzy ideas into clear requirements. Use when the user has a vague sense of what they want — a page that doesn't feel complete, a feature that's missing something, a direction without details. Walks every branch of the idea, asks one question at a time with a recommended answer, explores the codebase instead of asking when possible. Output: a requirements file in tasks/ ready to feed into writing-specs or software-design."
---

# Grill Me

Interview the user relentlessly about every aspect of their idea until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one by one.

For each question, provide your recommended answer. Ask questions one at a time, waiting for feedback before continuing. If a question can be answered by exploring the codebase, explore the codebase instead.

## The rule

**Never fill a gap with an assumption.** If something is unclear, ask. If you don't know, say so. If the user hasn't specified it, it is unspecified — not "obvious," not "standard," not "best practice." The moment you invent a requirement the user didn't state, you've poisoned everything downstream.

The failure mode: the user says "this page doesn't feel complete" and the AI invents 15 features, implements 8, and 6 are wrong. That happens because nobody stopped to ask what "complete" means. Your entire job is stopping to ask.

Every requirement in the output file must trace back to something the user said or confirmed — or something the codebase already does. If you can't point to where it came from, it doesn't go in the file.

## Before you start

1. **Read the project's `AGENT.md` or `CLAUDE.md`** for domain language. If a glossary exists, load it — you'll challenge terminology against it.
2. **Read relevant specs** in `docs/specs/` if they exist. Know what's already decided so you don't re-litigate settled ground.
3. **Scan the codebase** around the area being discussed. What exists today? What state is it in?

Surface what you found in 2-3 sentences. Then start grilling.

## How to grill

**One question at a time.** Wait for the answer before moving on. Never batch questions — batching lets the user skip the hard ones.

**Provide your recommended answer with every question.** Not "what do you want here?" but "I'd recommend X because Y — does that match what you're thinking, or is it different?" This gives the user something concrete to react to. It also surfaces your assumptions immediately so they can be corrected before they compound.

**If the codebase can answer it, don't ask.** Before asking "how does the current flow work?", look. Before asking "what components exist?", check. Only ask questions that require the user's judgment or domain knowledge.

**Walk down each branch of the design tree.** When the user describes a feature, decompose it into every path: happy path, error states, edge cases, empty states, loading states, mobile vs desktop, first-time vs returning user. Walk each branch. Most missing requirements live in branches nobody thought about.

**Sharpen fuzzy language.** When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'handle errors gracefully' — what does the user see when the payment API is down? What does 'gracefully' mean here specifically?" Vague requirements produce vague implementations.

**Challenge terminology against the glossary.** When the user uses a term that conflicts with the Domain Language in the project's docs, call it out immediately. "Your glossary defines 'attendee' as someone who's paid. You just said 'attendee' for someone still registering — do you mean 'registrant', or should we update the glossary?"

**Discuss concrete scenarios.** When domain relationships come up, stress-test them with specific examples. Invent scenarios that probe edge cases and force the user to be precise about boundaries between concepts.

**Cross-reference with code.** When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "You said guest pricing applies to children, but `calculatePricing()` treats children as a separate tier — which is right?"

## What to grill on

For every feature or page, probe these dimensions:

**Users & access**: Who sees this? Who doesn't? What if they're not authorized? Different user types?

**Content & data**: What's shown? Where does it come from? What if it's missing, empty, or stale? Maximum/minimum? Truncation?

**Interactions**: What can the user do? What happens on each action? Confirmation/feedback? Undo?

**States**: Loading, empty, error, partial, success, disabled. What does each look like?

**Validation**: What are the rules? When are they checked? What are the error messages — exact wording?

**Sequences**: What comes before? What comes after? Can the user go back? What's preserved?

**Devices**: Mobile vs desktop differences? Touch targets? Responsive breakpoints?

**Edge cases**: Duplicate submissions? Browser back button? Refresh mid-flow? Timeout? Slow connections?

## Pacing

Most sessions should be 8-15 questions. If you're past 20, you're probably going too deep on one area — step back and check if other areas are uncovered.

If the user gives short answers, that's fine — they might be certain. If they give long answers, there's usually a buried requirement in the story. Pull it out: "So what I'm hearing is X — is that a hard requirement or a nice-to-have?"

## When to stop

You're done when:
- Every branch of the tree has been walked (or explicitly deferred)
- No question you can think of would change the implementation
- The user says "that's it" or "let's build"

You're NOT done when:
- You've asked your quota of questions
- The user seems impatient (impatience is not the same as completeness)
- You've covered the happy path but not the edge cases

## Output

When the session is done (or the user says to wrap up), write the requirements to:

```
tasks/YYYY-MM-DD-<slug>.requirements.md
```

The file contains only what was decided or confirmed during the session:

```markdown
# <Topic> — Requirements

Source: grill-me session, <date>
Status: [COMPLETE | PARTIAL — <what's still open>]

## <Area 1>

- R1: <requirement in plain language>
- R2: <requirement>
  - R2.1: <sub-requirement if needed>

## <Area 2>

- R3: <requirement>

## Open Questions

- [OPEN] <thing that wasn't resolved, with context on why>

## Next Step

→ writing-specs | software-design | keep grilling
```

**Rules for the output file:**
- Every requirement traces to something the user said, confirmed, or the codebase already does
- No invented requirements — if the user didn't address it and the code doesn't cover it, it goes under Open Questions
- Use the project's canonical terminology
- Plain language, not implementation language — "the user sees X" not "render component Y"
- Number requirements (R1, R2, R2.1) so specs and tests can reference them precisely

After writing the file, ask: write the spec, start the design, or keep grilling?
