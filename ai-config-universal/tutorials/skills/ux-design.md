# UX Design Skill — Tutorial

**Tier:** 🔵 Situational (building or reviewing UI)
**Type:** Skill (you stay in the driver's seat)
**Full skill:** `skills/ux-design/SKILL.md`

---

## What It Does

Two modes in one skill:
1. **Building UI** — design system thinking; primitives-first workflow
2. **Reviewing UI** — structured friction audit with specific, actionable findings

---

## When to Use It

**Building mode:**
- Starting a new UI feature — before designing the first screen
- Making sure you're using consistent spacing, color, and typography
- Building a component that should match the rest of the app

**Review mode:**
- After building a UI — does it work for users?
- Something feels off but you can't name it
- Pre-ship QA on a new page or flow

---

## How to Invoke

**Building mode (Copilot Chat):**
```
@workspace Read skills/ux-design/SKILL.md — 
use the Primitives-First workflow to help me design 
the notification preferences page.
```

**Review mode:**
```
@workspace Read skills/ux-design/SKILL.md — 
use the Review workflow on this screenshot/description:
[attach screenshot or describe the UI]
```

**Claude Code / AGY:** "Review this UI for friction...", "Design this page using UX principles..." triggers it.

---

## Building Mode: Primitives First

Before designing any screen, establish (or reference) the system:

```
Colors:    primary=#2563EB, success=#16A34A, error=#DC2626, 
           neutral-50 through neutral-900
Spacing:   4px base unit → 4/8/12/16/24/32/48/64px scale
Type:      base=16px, scale ratio=1.25 → 12/14/16/20/25/31px
           weights: 400 (body), 600 (heading), 700 (emphasis)
Components: Button (primary/secondary/ghost/destructive)
           Card, Input, Label, ErrorMessage
```

Every UI decision references this system. "Which shade of blue?" → `primary`. "How much padding?" → `16px` (1 unit × 4). This is what makes the app look like one product.

---

## Review Mode: The Friction Audit

The skill runs the UI through 7 checks:

```
1. Job to be done: What is the user trying to accomplish?
2. Squint test: What's the first thing they see? Is it the primary action?
3. Friction audit: Where will they hesitate? Step-by-step.
4. Accessibility: Contrast ratios, touch targets, keyboard nav.
5. System check: Colors from palette? Spacing from scale?
6. State coverage: Empty, loading, error, success all handled?
7. Recommended changes: Specific fixes with severity labels.
```

**Sample output:**
```
## UX Review — Notification Preferences Page

Job to be done: User wants to control which notifications they receive.

Squint test: ✅ Toggle switches are visible and draw the eye correctly.

Friction findings:
- MAJOR: No grouping — 14 individual toggles with no categories. 
  User has to read every one to find what they want.
  Fix: Group into: "Account", "Activity", "Marketing" sections.
  
- MAJOR: No "turn off all" option. Turning off notifications 
  requires 14 individual actions.
  Fix: Add "Mute all" toggle at the top.

- MINOR: Toggle labels use system names ("EMAIL_NOTIF_ACCT_SECURITY")
  not human language ("Account security alerts").
  Fix: Use plain language labels.

Accessibility:
- CRITICAL: Toggle contrast ratio is 2.8:1 (requires 4.5:1 minimum)
  Fix: Use #1a1a1a on #ffffff instead of #6b7280

System check:
- ⚠️  Spacing between items is 10px — not on the 4px scale. 
     Use 8px or 12px.
```

---

## The 2-Second Test

Show the screen to someone. Within 2 seconds they should know what to do.

If they pause, squint, or ask "what does this do?" — the hierarchy failed.

---

## Time Investment

- Building mode setup: 20-30 minutes (one-time per project)
- Review: 15-20 minutes per page
- Saves: confusing UX, accessibility violations, design inconsistency
