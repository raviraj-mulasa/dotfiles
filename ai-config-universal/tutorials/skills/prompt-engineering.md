# Prompt Engineering Skill — Tutorial

**Tier:** ⚪ Situational (use when writing or refining prompts/skills/agents)
**Type:** Skill (you stay in the driver's seat)
**Full skill:** `skills/prompt-engineering/SKILL.md`

---

## What It Does

Guides you through refining, structuring, and improving system prompts, skill instructions, and agent role definitions using field-tested techniques:
- Treating the AI like a smart teammate who needs context and judgment, not exhaustive micro-rules.
- Structuring prompt inputs with clear delimiters (Markdown, XML tags) to separate instructions, examples, and user context.
- Running the "Teammate Test" to catch hidden assumptions before executing expensive runs.

---

## When to Use It

- Writing a new custom skill or agent role definition
- Improving a prompt that fails intermittently or generates verbose/off-target responses
- Refactoring bulky system prompts to conserve tokens without sacrificing quality
- Setting up few-shot examples that illustrate patterns without leaking superficial formatting quirks

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/prompt-engineering/SKILL.md and review 
my prompt in [path/to/prompt.md] for clarity and token efficiency.
```

**Claude Code:**
```
Use the prompt-engineering skill to help me refine this system prompt for our data pipeline agent.
```

**AGY:** "Improve this prompt...", "Review prompt engineering in..." triggers it.

---

## Key Principles Applied

| Principle | Why It Matters |
|---|---|
| **Context Over Rules** | Explain the *why* so the model can generalize to unpredicted edge cases |
| **Nudge, Don't Tutor** | Don't re-explain basic concepts the model already knows; guide behavior directly |
| **Structural Demarcation** | Use Markdown headings or XML tags so instructions, context, and examples don't blur |
| **Teammate Test** | Ask: "Would a smart engineer walking into the room cold understand what to do?" |

---

## Real Example

**Input Prompt:**
```
You are a helper. Summarize the user's PR. Do not be long. Make sure to check tests.
```

**Refined Output:**
```markdown
# PR Summary Specialist

You generate concise, high-signal pull request summaries for peer reviewers.

## Review Focus
1. **Core Intent**: In 1–2 sentences, what problem does this PR solve?
2. **Behavior Changes**: Bullet points of user-facing or architectural changes.
3. **Verification**: Explicitly list how this was tested (unit tests, manual curl, logs).

Keep the summary under 30 lines. Avoid repeating boilerplate commit messages.
```
