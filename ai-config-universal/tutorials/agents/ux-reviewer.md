# UX-Reviewer Agent — Tutorial

**Tier:** 🔵 Situational (UI & Flow Auditing)
**Type:** Agent (friction and usability audit)
**Full agent:** `agents/ux-reviewer.md`

---

## What It Does

Acts as a Principal UX Researcher and Auditor. Evaluates UI designs, user flows, and wireframes for **friction, cognitive load, and accessibility issues** based on "usable, not pretty" principles (Krug's Law, Nielsen Norman heuristics, WCAG 2.1 AA+).

---

## When to Use It

- After designing a new checkout, signup, or onboarding flow
- Reviewing settings pages, complex forms, or dashboard layouts
- Auditing error states, loading feedback, and empty states for user friction
- Checking accessibility and keyboard navigability

---

## How to Invoke

**Copilot Chat:**
```
@workspace Act as the ux-reviewer defined in agents/ux-reviewer.md. 
Audit the checkout form in src/components/Checkout.tsx for usability friction.
```

**Claude Code:**
```
Use the ux-reviewer agent to review the notification settings flow we designed in tasks/notifications.spec.md
```

**AGY:** "Review UI usability...", "UX audit of..."

---

## What It Evaluates

1. **Cognitive Load (Krug's Law)**: Does the user hesitate or guess what an action does?
2. **Visibility of System Status**: Are loading, success, and error feedback immediate and explicit?
3. **Error Prevention & Recovery**: Are errors clear, actionable, and non-punitive?
4. **Accessibility**: Contrast, keyboard navigation, and WCAG standards.
