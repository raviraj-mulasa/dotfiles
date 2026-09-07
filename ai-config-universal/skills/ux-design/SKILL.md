---
name: ux-design
description: UX design knowledge base and review methodology — principles, systems thinking, quality criteria, anti-patterns, and structured UX auditing. Use both when building UI (design system thinking) and when reviewing/auditing UI for friction. Triggers on 'UX', 'design system', 'review UI', 'usability', 'friction audit'.
---

# UX Design

Design knowledge and review methodology for building and auditing user interfaces.

---

## UX Knowledge Base

### Design Philosophy

**Systems, Not Screens**

Before designing a button, ask: "What's the button system?"
Before picking a color: "What's the color system?"
Before adding spacing: "What's the spacing rhythm?"

Screens are compositions. Primitives are the instruments. Define the orchestra first, then compose.

**Rhythm and Repetition**

Great design has musicality. Elements repeat. Patterns echo. There's a beat.

When a user moves through the interface, they should feel it — "this card behaves like that card," "this spacing feels like that spacing." Rhythm creates trust. Novelty creates friction.

**Beautiful Design is Inclusive**

Low contrast isn't just inaccessible — it's lazy. Tiny touch targets aren't just hard to use — they're unfinished. Keyboard-unfriendly interfaces aren't just exclusive — they're incomplete.

Accessibility is a quality bar, not a checklist.

**Obvious Over Clever**

If a user has to figure out how something works, it's a failure. Clever design impresses designers. Obvious design serves users.

**Restraint**

The instinct is to remove, not add. Every element justifies its existence. White space is not empty — it's breathing room.

The best design is the one with nothing left to take away.

---

### Primitives-First Workflow

Don't start with screens. Start with building blocks.

**Step 1: Check What Exists**

Look for an existing style guide (`docs/STYLE_GUIDE.md`). If it exists, compose within the established system. Consistency across the app matters more than local optimization.

**Step 2: Establish Primitives**

If no style guide exists, define these BEFORE designing features:

*Colors* — Brand (primary, secondary), Semantic (success, warning, error, info), Neutrals (background, surface, border, text tiers)

*Typography* — Type scale using a ratio (e.g., 1.25 Major Third): xs/sm/base/lg/xl/2xl. Font family. Weights: 400/500/600/700.

*Spacing* — Base unit: 4px. Scale: 4/8/12/16/24/32/48/64px with defined usage for each.

*Components* — Buttons (primary/secondary/ghost/destructive), Cards, Forms (inputs, labels, errors, help text), Feedback (toasts, alerts, loading, empty states).

**Step 3: Store the Guide**

Save primitives to `docs/STYLE_GUIDE.md`. This is the source of truth. Every future feature references it. When a new decision is made (new component, new pattern), add it here.

**Step 4: Compose Features**

Design screens by assembling primitives. Don't ask "what color?" — ask "which color from the system?" The feature should feel like it was always part of the app.

---

### Quality Bar

**Visual Coherence**
- All colors from the defined palette
- All spacing from the defined scale
- All typography uses the defined hierarchy
- Components match established patterns

**Rhythm Check**
- Repeated elements are truly identical (not "similar")
- Spacing is consistent, not "close enough"
- Clear visual hierarchy

**State Coverage**
- Empty state — what does the user see with no data?
- Loading state — skeleton screens preferred over spinners
- Error state — inline, specific, actionable
- Success state — confirmation before transition
- Hover/Focus/Active — every interactive element

**Accessibility (Non-Negotiable)**
- 4.5:1 contrast for all text
- 44x44px minimum touch/click targets
- Visible focus indicators
- Works with keyboard only
- No information conveyed by color alone

**The 2-Second Test**

Show the screen to someone. They should know what to do within 2 seconds. If they pause, squint, or ask "what does this do?" — redesign it.

---

### Motion & Animation

Animation isn't decoration. It has specific jobs in an interface:

| Job | What it means |
|-----|--------------|
| **Orient** | Where am I? Where did that come from? |
| **Respond** | The system heard me. Something happened. |
| **Guide** | Look here. Do this next. |
| **Connect** | These things are related. This became that. |
| **Wait** | Something is happening. Here's how long. |
| **Delight** | A moment of personality or celebration. |

Every animation must have a job from this table. "Looks cool" is not a job.

Quick quality check:
- Never use linear easing — it feels robotic
- Micro-interactions: 100–300ms. Page transitions: 300–500ms. Never >500ms for UI.
- `prefers-reduced-motion` must be honored — this is accessibility, non-negotiable
- Same action = same animation everywhere

---

### Anti-Patterns

**Inconsistency** — Two buttons that look almost-but-not-quite the same. Pick one.

**Orphan elements** — A one-off component that doesn't fit the system. Systematize it or kill it.

**Competing hierarchy** — Multiple things screaming for attention. One primary action per screen.

**Clever interactions** — Gestures, hidden menus, hover-reveals that aren't obvious. Boring is better.

**Decoration without purpose** — Gradients, shadows, borders that don't communicate hierarchy. Remove them.

**Walls of text** — Paragraphs where bullet points would do. Users scan, they don't read.

---

## UX Review

### Mindset: You Own This

Not following design rules. Not checking boxes. You ARE a designer.

This is your work. When someone uses this interface, they're experiencing something you made. Take ownership. Have opinions. Make choices. When you see something wrong, say so with specificity — not "consider improving contrast" but "this 3.1:1 contrast fails WCAG AA; use #1a1a1a on this background."

---

### Review Workflow

**1. Clarify What's Being Reviewed**

If the user provided a specific artifact (screenshot, file, plan), use that. If not, ask:
- What UI/flow/feature should I review?
- Do you have a screenshot, wireframe, or description?
- What's the main user goal this serves?

**2. Job to Be Done**

What is the user actually trying to achieve? State it as a verb: "User wants to [action]." Everything else is evaluated against that.

**3. Squint Test**

What's the first thing they see? Is it the primary action? The squint test reveals hierarchy — blur your eyes and see what draws attention.

**4. Friction Audit**

Where will they hesitate, get confused, or fail? Work through the flow step by step:
- What decision is the user making here?
- What information do they need that isn't visible?
- What could go wrong at this step?
- What information are we asking for that we should already know?

**5. Accessibility Check**

- Contrast ratios for all text (minimum 4.5:1)
- Tap/click target sizes (minimum 44x44px)
- Keyboard-only navigation — does it work?
- Screen reader logic — does the DOM order make sense?
- `prefers-reduced-motion` support

**6. System Check**

- Colors from the palette? Spacing from the scale? Components matching the guide?
- Any orphan elements that don't fit?
- Any states missing (empty, loading, error, success)?

**7. Recommended Changes**

Propose specific fixes. Label by severity:
- **Critical** — Breaks the user's ability to complete the task
- **Major** — Significant friction or confusion
- **Minor** — Polish, consistency, or accessibility improvement

Be direct and slightly critical but constructive. This is an audit, not cheerleading. Provide specific, actionable fixes — not vague "consider improving."

**8. Micro-copy**

If text is part of the friction, rewrite it. Concrete suggestions, not "make this clearer."

---

### Reviewing a Plan or Feature (No Visuals)

Walk through the conceptual flow as if you were the user:
- What screens/steps would this involve?
- Where are the decision points?
- What could go wrong at each step?
- What information is the user expected to provide vs. what should be inferred?

Apply the same principles: progressive disclosure, error prevention, clear next steps, minimal cognitive load.

---

### When to Speak Up vs. Just Act

**Speak up when:**
- An inconsistency that will compound if not addressed
- A proposed design that violates the system
- A real tradeoff worth discussing
- A strong opinion (allowed and encouraged)

**Just act when:**
- Applying established patterns
- The right choice is obvious
- Explaining would take longer than doing

---

## How to Use This Skill

**When building UI:**
1. Check `docs/STYLE_GUIDE.md` — what's established?
2. Design with existing primitives — don't invent new ones
3. If something new is needed, add it to the guide so it becomes part of the system

**When reviewing UI:**
1. Run the Review Workflow above
2. Check system violations — colors, spacing, components that don't match
3. Check state coverage — empty, loading, error, success, interactive states

**When no style guide exists:**
1. Look at what's already built — extract the implicit system
2. Document it in `docs/STYLE_GUIDE.md`
3. Now you have a foundation for coherent future work

---

## Remember

**You're not decorating. You're composing.** Every element relates to every other element. The whole must feel like one thing.

**Primitives are power.** A small set of well-designed building blocks beats infinite one-off solutions.

**Consistency beats local perfection.** A slightly-less-perfect button that matches all others is better than a perfect button that's unique.

**The style guide is alive.** It grows with the product. Reference it, add to it, protect it.

**Usable, not pretty.** We're not here to make it look nice — we're here to make it work for humans.

**Every hesitation is friction.** Find it. Name it. Fix it.
