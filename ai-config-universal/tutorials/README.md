# Tutorials Index

Individual tutorials for every solo-developer-relevant skill and agent.
Each tutorial covers: what it does, when to use it, how to invoke it, what to expect, and a real example.

---

## 🟢 Tier 1 — Core & Daily Use

### Skills
| Tutorial | What it's for |
|---|---|
| [spec-driven-development.md](./skills/spec-driven-development.md) | **The pipeline** — connects all other skills into SDD workflow |
| [debugging.md](./skills/debugging.md) | Something is broken and you don't know why |
| [writing-implementation-plans.md](./skills/writing-implementation-plans.md) | Before any change touching 3+ files |

### Agents
| Tutorial | What it's for |
|---|---|
| [engineer.md](./agents/engineer.md) | Default reasoning workhorse for building and refactoring |
| [fast-worker.md](./agents/fast-worker.md) | Fast, cheap worker for bounded mechanical tasks (grep, tests) |
| [code-reviewer.md](./agents/code-reviewer.md) | 3-pass review after finishing any feature |
| [commit-curator.md](./agents/commit-curator.md) | Organize clean commits before every push |
| [pr-description-writer.md](./agents/pr-description-writer.md) | Generate high-signal PR summaries before opening PR |

---

## 🟡 Tier 2 — Weekly Workflows

### Skills
| Tutorial | What it's for |
|---|---|
| [grill-me.md](./skills/grill-me.md) | Fuzzy idea → clear requirements |
| [software-design.md](./skills/software-design.md) | Designing a new component or API contracts |
| [writing-unit-tests.md](./skills/writing-unit-tests.md) | Writing tests that catch real bugs |
| [code-quality.md](./skills/code-quality.md) | Simplifying and cleaning up code |

### Agents
| Tutorial | What it's for |
|---|---|
| [security-reviewer.md](./agents/security-reviewer.md) | Threat modeling and security audit before shipping |

---

## 🔵 Tier 3 — Situational & Specialized

### Skills
| Tutorial | What it's for |
|---|---|
| [brainstorming.md](./skills/brainstorming.md) | Stuck on a design decision |
| [writing-specs.md](./skills/writing-specs.md) | Complex feature needs formal requirements |
| [writing-qa-plan.md](./skills/writing-qa-plan.md) | Feature has multiple behaviors to verify |
| [ux-design.md](./skills/ux-design.md) | Building or reviewing UI |
| [sprint.md](./skills/sprint.md) | Large feature decomposed into parallel tasks |
| [prompt-engineering.md](./skills/prompt-engineering.md) | Writing or improving AI prompts, skills, and agents |

### Agents
| Tutorial | What it's for |
|---|---|
| [codebase-explorer.md](./agents/codebase-explorer.md) | Mapping an unfamiliar codebase |
| [implementation-reviewer.md](./agents/implementation-reviewer.md) | Completeness check after finishing a feature |
| [qa-dev.md](./agents/qa-dev.md) | Adversarial tests for critical features |
| [ux-reviewer.md](./agents/ux-reviewer.md) | Friction and usability audit for user flows |
| [visual-qa-lead.md](./agents/visual-qa-lead.md) | Visual, functional, and design quality gatekeeper |
| [sprint-dev.md](./agents/sprint-dev.md) | Builder for isolated sprint task bricks |
| [minion.md](./agents/minion.md) | High-volume text processing and log analysis |

---

## Quick Invocation Reference

### GitHub Copilot (VSCode / JetBrains)
```
@workspace Read skills/[skill-name]/SKILL.md and [what you want]
@workspace Read agents/[agent-name].md and [what you want]
```

### Claude Code
```
Use the [skill/agent name] skill/agent [for/on] [what you want]
```

### AGY (Antigravity)
Just describe what you want — AGY triggers skills automatically based on keywords.
Or explicitly: *"Use the [name] skill/agent"*

---

## The Workflow That Covers 90% of Solo Dev Work

```
1. Fuzzy idea?          → grill-me
2. Before coding:       → writing-implementation-plans
3. While coding:        → debugging (when stuck)
4. After coding:        → code-reviewer + security-reviewer (if needed)
5. Before push:         → commit-curator
6. Before PR:           → pr-description-writer
```
