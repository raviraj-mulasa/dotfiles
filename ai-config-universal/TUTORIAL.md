# AI-Config-Universal: Solo Developer Tutorial

> You don't need all 13 agents and 14 skills. Most solo dev work needs 6-8.
> This guide tells you which ones matter, when to reach for them, and exactly how to invoke them.

---

## The Big Picture: The SDD Blueprint

Everything in this config plugs into the **Spec-Driven Development (SDD)** pipeline. The spec is the source of truth — not the code, not your memory. Every feature travels this pipeline:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SDD PIPELINE — SOLO DEVELOPER                    │
├────────┬──────────────────────────┬──────────────────────────────────┤
│ Stage  │ What happens             │ Tool                            │
├────────┼──────────────────────────┼──────────────────────────────────┤
│   0    │ Fuzzy idea → requirements│ grill-me skill                  │
│   1    │ Requirements → spec      │ writing-specs skill             │
│   2    │ Spec → test cases        │ writing-qa-plan skill           │
│   3    │ Spec → architecture      │ software-design skill           │
│   4    │ Design → task breakdown  │ writing-implementation-plans    │
│   5    │ Build it                 │ engineer / fast-worker agents   │
│   6    │ Did I build it right?    │ implementation-reviewer +       │
│        │                          │ code-reviewer + security-review │
│   7    │ Requirements change?     │ writing-specs (maintain mode)   │
└────────┴──────────────────────────┴──────────────────────────────────┘
```

**Scale to your feature size — you don't always need all stages:**

| Feature size | Minimum stages |
|---|---|
| 🔴 Large (6+ files, complex) | 0 → 1 → 2 → 3 → 4 → 5 → 6 |
| 🟡 Medium (3-5 files) | 1 → 2 → 4 → 5 → 6 |
| 🟢 Small (1-2 files, clear) | 1 → 5 → 6 |
| 🐛 Bug fix | Skip pipeline — debug → fix → code-reviewer |

> **Full pipeline details:** `tutorials/skills/spec-driven-development.md`

---

## The Simple Mental Model

Think of **skills** and **agents** as two different things:

| | Skills | Agents |
|---|---|---|
| **What** | A workflow *you* follow with AI help | A specialist AI that takes over a task |
| **When** | You stay in the driver's seat | You hand off the task completely |
| **Example** | "Help me debug this using the debugging workflow" | "Review my code and report back" |

---

## Solo Developer: What You Actually Need

### 🟢 Tier 1 — Use These Every Day

| Tool | SDD Stage | When to use it |
|---|---|---|
| `spec-driven-development` skill | Orchestrator | Starting any non-trivial feature |
| `debugging` skill | — | Something is broken and you don't know why |
| `writing-implementation-plans` skill | Stage 4 | Before any change touching 3+ files |
| `code-reviewer` agent | Stage 6 | After finishing any feature |
| `commit-curator` agent | — | Before pushing — clean commit history |
| `pr-description-writer` agent | — | Before opening a PR |

### 🟡 Tier 2 — Reach for These Weekly

| Tool | SDD Stage | When to use it |
|---|---|---|
| `grill-me` skill | Stage 0 | Fuzzy idea → clear requirements |
| `writing-specs` skill | Stage 1 | Turning requirements into formal spec |
| `writing-qa-plan` skill | Stage 2 | Test cases from spec before you design |
| `software-design` skill | Stage 3 | Designing a new component or API |
| `writing-unit-tests` skill | Stage 5 | Writing tests that actually catch bugs |
| `code-quality` skill | Stage 6 | Simplifying code after a messy sprint |
| `security-reviewer` agent | Stage 6 | Before anything touches auth, input, or data |

### 🔵 Tier 3 — Situational (Use When the Situation Arises)

| Tool | When |
|---|---|
| `brainstorming` skill | Stuck on a design decision |
| `ux-design` skill | Building or reviewing UI |
| `sprint` skill | Decomposing a large feature into parallel tasks |
| `codebase-explorer` agent | Jumping into an unfamiliar codebase |
| `implementation-reviewer` agent | Stage 6 — completeness check after finishing |
| `qa-dev` agent | Adversarial tests for critical features |

### ⚪ Tier 4 — Team-Oriented (Less Relevant Solo)

| Tool | Why less relevant solo |
|---|---|
| `minion` agent | High-volume delegation to a cheaper model — advanced usage |
| `sprint-dev` agent | The builder inside a full multi-agent sprint |
| `visual-qa-lead` agent | Needs browser automation setup |
| `ux-reviewer` agent | Overlaps with `ux-design` skill for solo work |
| `prompt-engineering` skill | Only needed when writing your own skills/agents |

---

## How to Invoke: Platform-Specific

### GitHub Copilot (VSCode or JetBrains)

Copilot Chat doesn't auto-load skills. Reference them explicitly:

```
@workspace Read skills/spec-driven-development/SKILL.md and 
walk me through the SDD pipeline for: [feature name]
```

```
@workspace Read skills/debugging/SKILL.md and apply the 
debugging workflow to this error: [paste error]
```

```
@workspace Read agents/code-reviewer.md and review 
the changes in src/auth/login.py
```

**Tip:** Start each Copilot Chat session with `Read AGENT.md` to set engineering context.

---

### Claude Code

Claude Code reads `CLAUDE.md` automatically — engineering principles are always active. For skills, just name them:

```
Use the spec-driven-development skill for: adding OAuth login
```

```
Use the debugging skill to investigate why session cleanup 
is causing duplicate processing.
```

```
Use the writing-implementation-plans skill before we 
implement the payment webhook handler.
```

---

### AGY (Antigravity)

AGY loads `.agents/rules/engineering-principles.md` automatically. Skills trigger by keyword:

| You say... | AGY loads... |
|---|---|
| "SDD pipeline for..." | `spec-driven-development` skill |
| "debug this error" | `debugging` skill |
| "review my code" | `code-reviewer` agent |
| "I have a fuzzy idea..." | `grill-me` skill |
| "design this feature" | `software-design` skill |
| "write a spec for..." | `writing-specs` skill |

---

## Practical Examples: The SDD Pipeline in Action

### Scenario 1: Starting a new feature (Medium — 3-5 files)

**You:** "I need to add OAuth login (Google + GitHub) to the app."

This is a medium feature — use stages 1, 2, 4, 5, 6.

**Stage 1 — Specify:**
```
Use the writing-specs skill to create a spec for OAuth login.
We want Google + GitHub as providers. Users should be able to 
link multiple providers to one account.
```
*Output: `docs/specs/oauth.spec.md`*

**Stage 2 — QA Plan:**
```
Use the writing-qa-plan skill on docs/specs/oauth.spec.md
```
*Output: `tasks/2025-09-02-oauth.qa-plan.md` — test cases before design*

**Stage 4 — Plan:**
```
Use the writing-implementation-plans skill to create an 
implementation plan for OAuth.
Spec: docs/specs/oauth.spec.md
```
*Output: `tasks/2025-09-02-oauth.plan.md`*

**Stage 5 — Implement** *(regular coding, guided by the plan)*

**Stage 6 — Confirm:**
```
Use the code-reviewer agent on src/auth/
Use the security-reviewer agent on src/auth/ — focus on 
token handling, callback validation, state parameter.
```

---

### Scenario 2: Bug fix (no pipeline needed)

```
Use the debugging skill.

Error: "Session expires immediately after login on Safari only"
Works fine on Chrome. I think it's SameSite cookie settings 
but I'm not sure.
```

The debugging skill forces you through: list all hypotheses → observe → confirm → fix. No jumping to the first guess.

---

### Scenario 3: Feature too fuzzy to spec (start at Stage 0)

**You:** "I want some kind of analytics dashboard. Not sure what exactly."

```
Use the grill-me skill. I want to add an analytics dashboard 
to the app. Interview me to figure out what that means.
```

After 10-15 minutes of questions → `tasks/2025-09-02-analytics.requirements.md` → then Stage 1 (writing-specs).

---

### Scenario 4: Before pushing

```
Use the commit-curator agent on my staged changes.
```

Then:
```
Use the pr-description-writer agent for these changes.
I fixed the OAuth callback race condition — issue #87.
```

---

### Scenario 5: Jumping into unfamiliar code

```
Use the codebase-explorer agent to map this repo.
Produce tasks/codebase-orientation.md
```

*Takes 30-45 minutes. Future agents read the orientation doc before starting any task.*

---

## The Solo Dev Cheat Sheet

```
Starting a feature?
  → spec-driven-development skill (pick your stages by size)
  → grill-me (if fuzzy → Stage 0)
  → writing-specs (always → Stage 1)
  → writing-qa-plan (medium+ features → Stage 2)
  → writing-implementation-plans (always, if 3+ files → Stage 4)

While coding?
  → debugging (when stuck)
  → code-quality (when it gets messy)
  → writing-unit-tests (write tests alongside code)

Before pushing?
  → implementation-reviewer (did I miss anything?)
  → code-reviewer (is the code good?)
  → security-reviewer (auth/input/data involved?)
  → commit-curator (clean commits)
  → pr-description-writer (clear PR)

Designing something new?
  → brainstorming (explore options)
  → software-design (define contracts → Stage 3)

Building UI?
  → ux-design (design principles + review)

New codebase?
  → codebase-explorer (orientation map)
```

---

## The SDD Traceability Chain

This is what SDD gives you that ad-hoc development doesn't:

```
Bug filed: "OAuth login fails for users with + in their email"
  ↓
Find in spec: R3.2 — "Email addresses must be handled as opaque strings"
  ↓
Find in QA plan: TC-12 — "Given: email with special characters, When: login..."
  (TC-12 was never run — that's how the bug shipped)
  ↓
Find in code: OAuthCallback.parse_user() in src/auth/oauth.py:L67
  ↓
Fix: URL-decode email before parsing
  ↓
Add TC-12 to the regression suite — spec was correct, test was missing
```

Every bug has a home in the spec. If it doesn't → the spec is incomplete → add it before fixing the code.

---

## Start Here: Your First Week

**Day 1:** Try `debugging` skill on a real bug you're working on.

**Day 2:** After your next feature, try `code-reviewer` agent.

**Day 3:** Before your next multi-file change, try `writing-implementation-plans`.

**Day 4:** Before your next push, try `commit-curator` + `pr-description-writer`.

**Day 5:** Start your next feature with `writing-specs` → `writing-qa-plan`. See how it changes what you build.

After that: try `grill-me` the next time you have a fuzzy idea. Try `security-reviewer` the next time you touch auth.

The SDD pipeline isn't all-or-nothing. Add one stage at a time until it's natural.
