# Visual QA Lead Agent — Tutorial

**Tier:** 🔵 Situational (Visual QA & Design Quality)
**Type:** Agent (visual and functional UI gatekeeper)
**Full agent:** `agents/visual-qa-lead.md`

---

## What It Does

Acts as the adversarial gatekeeper for user interfaces. Plans visual test sessions, orchestrates UI review, and synthesizes evidence into severity-ranked reports covering **functional correctness, interaction rhythm, and design system fidelity**.

---

## When to Use It

- Before shipping major frontend features or UI redesigns
- Verifying responsive layouts across desktop and mobile viewports
- Enforcing design system constraints (grid alignment, spacing tokens, typography hierarchy)
- Catching visual defects, card soup, or UI clutter

---

## How to Invoke

**Copilot Chat:**
```
@workspace Act as the visual-qa-lead defined in agents/visual-qa-lead.md. 
Review the dashboard UI in src/views/Dashboard.vue for visual and functional consistency.
```

**Claude Code:**
```
Use the visual-qa-lead agent to run a pre-ship QA audit on the new reporting view.
```

**AGY:** "Visual QA for...", "Pre-ship design review..."
