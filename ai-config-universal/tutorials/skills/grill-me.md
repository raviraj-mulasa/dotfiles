# Grill Me Skill — Tutorial

**Tier:** 🟡 Use Weekly (when starting something fuzzy)
**Type:** Skill (interactive — you answer, AI asks)
**Full skill:** `skills/grill-me/SKILL.md`

---

## What It Does

Turns a vague idea into a clear requirements document through **structured Socratic questioning**. Asks one question at a time, always gives you a recommended answer to react to, and explores the codebase instead of asking you things it can look up itself.

Output: `tasks/YYYY-MM-DD-topic.requirements.md` — ready to feed into specs or design.

---

## When to Use It

- You have a feature idea but it's fuzzy: "I want a dashboard" / "users should be able to export data"
- You keep starting to design something and getting stuck on edge cases
- A feature has interactions with other parts of the system you haven't thought through
- You want to prevent "I built the wrong thing" before you build anything

**Skip it for:** well-understood features, bug fixes, refactoring.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/grill-me/SKILL.md and interview me 
about this feature idea: I want users to be able to export 
their data as CSV.
```

**Claude Code:**
```
Use the grill-me skill. Feature idea: user data export as CSV.
```

**AGY:** "Grill me about..." or "help me figure out what I want to build" triggers it.

---

## What Happens

The AI first scans the codebase for relevant context (what exists, what models are already there), then starts asking — **one question at a time**:

```
I looked at the codebase. You have a User model with 12 fields 
and a Transaction model with 8. No export functionality exists yet.

Let's figure out what "export data" means exactly.

Question 1: Who can export — all users, or only admins?
My recommendation: All users (export their own data only). 
This is simpler, more privacy-respecting, and fits GDPR 
right-to-data-portability requirements.
Does that match what you're thinking?
```

You answer. It asks the next question. 8-15 questions typically covers it.

---

## Sample Questions It Covers

- What data is included? What's excluded?
- What happens if the export is large (10,000 rows)?
- What does the user see while it's generating?
- Where does the file go — download immediately, or email link?
- What happens if it fails halfway through?
- Can users export again immediately, or is there a cooldown?
- Mobile? Or desktop only?

---

## The Output

```markdown
# Data Export — Requirements

Source: grill-me session, 2025-09-02
Status: COMPLETE

## Scope
- R1: Logged-in users can export their own data only
- R2: Export includes: transactions (all time), profile fields, preferences
- R3: Export excludes: internal IDs, soft-deleted records, payment card numbers

## Format
- R4: CSV format only (v1)
- R5: One file per export (not zip)

## UX
- R6: Export triggered by button on Settings → Data page
- R7: For exports <5s: file downloads immediately
- R8: For exports >5s: show "We'll email you a link" message

## Open Questions
- [OPEN] Max file retention: how long do we keep export links?

## Next Step
→ writing-specs
```

---

## Common Mistake

❌ Answering vaguely: "yeah something like that"
✅ Be specific. If you don't know, say "I haven't thought about that." The AI notes it as open.

---

## Time Investment

- Session: 15-25 minutes
- Saves: Building a feature wrong, missing edge cases that create bugs at launch
