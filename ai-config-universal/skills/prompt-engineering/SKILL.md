---
name: prompt-engineering
description: Review, write, refine, and iteratively improve AI agent prompts. Use for system prompts, skill instructions, role definitions, or any text that instructs an AI agent.
---

# Prompt Engineering

Treat the agent like a teammate you respect. Give them context. Explain why. Set realistic expectations. Trust them to make the right call when reality gets messy. Like a company that invests in culture instead of writing rules for every situation — you can't anticipate every case, so you set values and trust judgment. The techniques in this skill are what that respect looks like when written down. Not rules to memorize — what a thoughtful teammate would naturally do.

Understanding generalizes. Rules don't. So before you touch the delivery, understand the task. Before you apply principles, understand the domain. The substance comes first. The craft optimizes how it's delivered.

---

## Two modes

**Iterative mode** — you can run the prompt, watch it fail, fix the specific failure. Production prompts with a harness. Loop lives in `references/iterative-improvement.md`.

**Craft mode** — you can't easily test: skills, role definitions, one-shot prompts where running costs real money or time, anything where failures are rare and high-context. The loop is replaced by disciplined craft: pre-mortem, the teammate test, read-aloud, failure-mode audit, re-read after a day.

Most production prompts move toward iterative over time; most agent persona work stays in craft mode forever.

**The teammate test** — *Would a smart teammate who walked in cold be able to do this work from this prompt alone?* Brief the agent like a smart colleague who just walked into the room. Use it as the diagnostic when there's no eval.

---

## Prompt types

Not every prompt is the same artifact. The right density of context, constraints, and structure depends on what you're writing:

- **One-shot task prompt** — short lifetime, narrow audience, you'll see the output and can retry. Optimize for clarity over completeness.
- **System prompt** — runs every turn, sets the standing context. Worth more investment; lives with the model.
- **Auto-loaded skill** — runs only when triggered, but every time it triggers. Token cost recurs. Description must trigger precisely.
- **Agent role definition** — establishes identity and stance for an agent doing varied work. Heavier on values, lighter on rules; the agent generalizes from the frame.

Each has different constraints on length, lifetime, audience, error-correction loop.

---

## What you're actually building

A prompt is a composed artifact. It contains role, context, instructions, examples, data, constraints — sometimes all at once. The model needs to clearly distinguish what type each piece is. When types blur, behavior gets unpredictable.

### XML as structural backbone

Use XML tags to demarcate distinct content types. The model processes tagged sections differently from untagged prose.

**Right density test**: Would removing this tag let content blur or mix with surrounding material? If yes — keep it. If no — it's decoration, cut it.

Tags can carry both organizational AND instructional meaning in the same gesture. `<examples>` organizes the section AND can include a note like "for reference only — apply the principle, don't reproduce the form." That's two jobs in one tag, zero extra tokens.

Simple text formatting (headers, bullets, blank lines) handles more than you think. Reach for XML only when structure alone can't distinguish the content type.

**GOOD** — tag does work, plain text inside is already clear:
```
<memory>
  id1232323: The user wants to...
  id34545345: it is decided to...
</memory>
```

**BAD** — over-engineered, answering questions nobody asked:
```
<memory-index count="33">
    <m id="intern-mindset-positioning" kind="decision">Core positioning</m>
    ...
</memory-index>
```

The first version is clear. The second creates parsing work without adding clarity.

---

## Phase 0: Know the subject before you design the lesson

A coach who doesn't understand the sport can organize drills but can't tell you which play to run. Before reviewing or writing a prompt, understand what the agent needs to succeed. This is the work most prompt engineers skip.

1. **What is this task, really?** Not the label — the actual cognitive work. "Code review" is shallow. "Spot the bugs the author is blind to because they wrote it" is the real task.

2. **What's hard about it for an agent?** Every task has specific failure modes. Agents doing code review miss implicit state. Agents doing decomposition stop at the first level. Know where THIS agent on THIS task will drift.

3. **What domain knowledge needs to be active?** A prompt for database design should activate different knowledge than a prompt for UX review. The prompt's job is to activate the right weights.

4. **What does great look like vs merely adequate?** If you can't articulate the difference, you can't coach toward it.

5. **What evidence exists?** Has this prompt been used? What went wrong? Real failures are worth more than anticipated ones.

This phase produces the substance. Everything after optimizes delivery.

---

## Phase 1: Design the learning experience

Four questions in order. Each generates the right techniques — derive them, don't memorize them.

### 1. What frame does the model need before it starts?

Priming, role, and motivated constraints are all the same thing: set context before work begins.

**Prime, don't prescribe** — set a mindset, not a ruleset.

- Bad (rules not mindset): "You must follow these 12 rules when writing code."
- Good: "You write systems in the tradition of qmail — small, auditable, correct. Complexity is the enemy."

The second encodes a value system. The agent applies it to situations you didn't anticipate. The first gives 12 things to check, then breaks the moment a 13th situation arises.

**Role IS priming** — setting a role focuses the frame. It's not a separate concern.

- Example: "You are a senior systems engineer who treats complexity as a cost, not a feature."

The role activates an entire cluster of associated behaviors. You don't need to list them.

**Motivate constraints** — AI agents generalize from WHY, not WHAT. Explain the reason and it applies the principle to situations you didn't anticipate.

- Bad (no reason, can't generalize): "NEVER use ellipses"
- Good: "Never use ellipses — this will be read aloud by TTS and the engine won't know how to pronounce them."

The second version generalizes. The agent now understands the constraint well enough to apply it to em-dashes, parenthetical asides, anything that creates the same problem.

### 2. What must the model understand, not just follow?

The model already has the knowledge. Your job is to activate the right understanding, not teach it things it knows.

**Build the mental model first** — give the generator, not the rules. A narrative that connects everything produces different output than the same information as discrete sections.

- Diagnostic: Could the sections be shuffled without loss of meaning? If yes — you have a reference document, not a mental model. Add a narrative that connects everything before the sections begin.

**Nudge, don't tutor** — short reminders for things the agent tends to skip. Never explain what it already knows.

- Bad (tutors what agent already knows): "Test-driven development is a practice where you write tests before writing implementation code. This helps ensure..."
- Good: "Hard to test = bad design."

The second assumes knowledge. The first wastes tokens on a Wikipedia entry.

**Positive framing** — "do Y" encodes better than "don't do X". The model has to invert a negative instruction to know what to do. Skip the inversion.

- Bad (negative framing, doesn't say what to do): "Do not use markdown in your response"
- Good: "Write in smoothly flowing prose paragraphs."

The first forces the model to figure out what you DO want. The second just says it.

### 3. How should this be arranged so it's internalized, not just read?

Structure IS pedagogy. Ordering, demarcation, and placement all affect how information is processed. Same content, different outcomes.

**Progressive disclosure** — context when relevant, not front-loaded. Don't dump everything at the top that's only relevant to specific subtasks.

- Diagnostic: Is there a wall of context at the top only relevant to specific subtasks? Break it into sections the agent reaches when needed.

A context dump at the top costs attention. The agent processes all of it before knowing what's relevant. Structure so each piece of context appears when it's about to be used.

**Checks at point of action** — checks work when placed where the work happens, not grouped at the end in a self-review section the agent may skip.

- Bad (checks at end get skipped): A "Self-Review Checklist" section at the bottom with 10 items.
- Good: "Is this guarantee testable?" as a line inside the GUARANTEES definition.

The check that lives with the work gets applied. The check 200 lines later gets skipped.

**Contrast pairs at the decision point** — when the agent needs to make a quality judgment, show bad vs good right there. Always name the failure mode on bad examples — `Bad (reason): value`. "Bad" alone tells the agent nothing it can generalize from. The reason is the teaching.

```
Good: {"title": "Fix login button on mobile"}
Good: {"title": "Add OAuth authentication"}
Good: {"title": "Debug failing CI tests"}

Bad (too vague): {"title": "Code changes"}
Bad (too long): {"title": "Investigate and fix the issue where the login button does not respond on mobile devices"}
Bad (wrong case): {"title": "Fix Login Button On Mobile"}
```

Abstract instructions name a quality. Contrast pairs demonstrate it. And naming the failure mode lets the agent recognize the same pattern in cases you didn't show.

### 4. What constraints are real?

Only constrain what must be constrained. Every constraint has a cost — the agent optimizes for the constraint, which can crowd out optimizing for quality.

**No arbitrary constraints** — each one should prevent a specific, real failure.

- "Keep it under 500 lines" causes optimization for the line count, not quality.
- Diagnostic: For each constraint, ask "what real problem does this prevent?" If the answer is "it looks better" — cut it.

**Pre-mortem beats review** — "it's 6 months from now and this failed in production — find the holes" activates a different cognitive mode than "review this for correctness." Optimism bias is real. The pre-mortem frame defeats it.

**Start minimal, add from evidence** — every addition should trace to a specific observed failure. Don't anticipate problems — observe them, then fix.

- Diagnostic: Can every section trace back to "the agent got X wrong, so I added Y"? If not, it might be speculative bloat.

---

## When more words don't help

Knowing when to stop adding is part of the craft.

**Separate reviewer > longer prompt** — when an agent misses something, the fix isn't more instructions. It's a separate reviewer with fresh eyes. More text ≠ better output. If the prompt is growing because of quality problems, that's a signal to add a review pass, not a longer prompt.

**Structure for scan-find-act** — not read-everything-carefully. The agent scanning for what to do next shouldn't have to parse motivational language.

- Bad (can't be scanned): "It's really important that when you encounter an error, you take a moment to carefully consider the best approach, thinking about the user's needs, before crafting a thoughtful response."
- Good: "On error: log context, return the specific error type, no retries."

---

## Forks: where you'll drift

When you feel the pull toward adding more, take the second move.

| Situation | Lazy | Craft |
|---|---|---|
| Prompt feels short | Add a section | *Ask what's missing from the actual work* |
| Want to seem rigorous | Reach for XML | *Plain text; XML only when content types blur* |
| Agent misses something | Add a rule | *Add a reviewer with fresh eyes* |
| Behavior is wrong | "Don't do X" | *Tell it what to do instead* |
| New constraint occurs to you | Add it | *Trace it to an observed failure first* |
| Want to sound authoritative | Pile on imperatives | *Explain why; one sentence beats five rules* |

---

## How to Apply

The four questions work two ways: as a **design sequence** when writing, and as a **diagnostic** when reviewing.

### Writing a prompt

Phase 0 first — always. Then build the prompt in question order:

1. **Frame** — Open with role and mindset. Motivate every constraint with why.
2. **Understanding** — Write the mental model as a short narrative. Then add nudges for where this agent on this task will drift. Frame positively — what to do, not what to avoid.
3. **Arrangement** — Structure for progressive disclosure. Place checks where the work happens. Add contrast pairs at every quality judgment. Use XML tags to demarcate distinct content types — and only where plain formatting can't.
4. **Constraints** — Add only what prevents a real, observed failure. Nothing speculative.

Output: the prompt, plus a brief note on how Phase 0 insights shaped the design.

### Reviewing a prompt

Run the four questions as diagnostics. Each surfaces a different class of failure.

1. **Frame** — Read the first 5 lines. Do they set a mindset or jump to rules? Is there a role? Are constraints motivated with why?
2. **Understanding** — Could sections be shuffled without loss? Any tutorials explaining what the agent already knows? Any negatively framed instructions?
3. **Arrangement** — Is there a context dump at the top? Are checks grouped at the end? Are quality standards named without contrast pairs? Are XML tags earning their keep or decorating?
4. **Constraints** — Does each constraint prevent a real, specific failure? Can every section trace to an observed problem?

Output: the revised prompt, plus a brief note on what changed and why (tied to Phase 0 insights and the specific question it failed).

---

## Before you write

If you don't know what the prompt is for, you're not done brainstorming. The "Chosen / Why / Limitations / Reversal" from a finished brainstorm (see the `brainstorming` skill) maps directly into "role / motivated constraint / what this doesn't handle / when to revisit" in the prompt.
