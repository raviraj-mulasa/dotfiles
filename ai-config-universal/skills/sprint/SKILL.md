---
name: sprint
description: "Multi-step feature implementation through brick decomposition and parallel agent execution. This skill should be used when work requires structured decomposition into independently verifiable pieces, parallel agents, or evidence-gated waves."
---

# Sprint

Agents fail in predictable ways. They report success on partial work, overwrite each other in parallel, and test infrastructure instead of features. The sprint process is built around these failure modes — worktrees prevent overwrites, wave gates catch partial work, `guarantees_tested` forces real evidence. Every step exists because removing it caused a specific, documented failure.

The discipline is simple: build it up step by step, prove each step holds weight before the next one depends on it. A brick that "compiles" is not a brick that works. A test count is not evidence. A green CI run on infrastructure tests is not a shipped feature. At every step, the question is: **what would you show to prove this works?**

## Execution Model

The main agent orchestrates. Each phase runs as a **fresh sub-agent** with a curated input package; the main agent files the artifact and never absorbs the sub-agent's exploration. This keeps the main agent's context focused on judgment, not on raw exploration trails.

Three review tiers run on top:

- **T1** — cheap fast-worker compliance checks after every phase artifact is filed (presence + structure, not correctness)
- **T2** — one engineer adversarial review on the brick outline before tasks.json is written
- **T3** — engineer deep reviews at wave gates, milestones, and final sign-off

All compliance evidence is filed to `progress.md` as the audit spine. Stating the witness statement forces the orchestrator to actually do the work, and gives T1/T3/user something to verify against.

Pre-sprint setup: working tree is committed clean, a `sprint/<YYYY-MM-DD>-<task-slug>` branch is created, and all sprint work (including worktrees) branches from there. Sprint completion leaves the branch for the user to PR — no auto-merge.

---

## Workflows

- **Creating a sprint:** `references/creating-a-sprint.md`
- **Running a sprint:** `references/running-a-sprint.md`

## Supporting References

### Creating a sprint (planning session)

| Reference | When | Skip it and… |
|-----------|------|--------------| 
| `references/planning-funnel.md` | Input assessment — which upstream phases to run | You run the wrong phases. A medium feature skips design, bricks have no contracts, every downstream brick inherits the gap. |
| `references/orchestration-pattern.md` | Before dispatching any phase sub-agent — roles, prompts, cost discipline | You do phase work yourself instead of dispatching sub-agents. Context bloats, judgment degrades, output tokens explode (5x cost). |
| `references/brick-design.md` | Before decomposing bricks — schema, sizing, criteria, `files` field, design contracts | Bricks are task-shaped ("set up the data layer") instead of building-block-shaped. No `guarantees_tested`, no evidence at the gate, validation theater. |
| `references/wave-planning.md` | When ordering bricks into waves — testability layers, parallelism budget | Bricks land in waves by compilation order, not testability order. Foundation bugs compound silently because nothing was verifiable until wave 4. |
| `references/progress-schema.md` | When writing progress.md entries and T1 checklists | T1 checks have nothing to verify. No audit spine. Resume from interruption is impossible — no record of what passed or failed. |
| `references/failure-modes.md` | Understanding why each step exists; context for adversarial review | You skip steps that feel like overhead without knowing which sprint they saved. The adversarial review misses failure patterns it could have caught. |

### Running a sprint (execution session)

| Reference | When | Skip it and… |
|-----------|------|--------------| 
| `references/orchestration-pattern.md` | Before dispatching any wave — roles, agent selection, prompt skeletons, review tiers | You self-assess Level 3 instead of dispatching T1R. You stuff context into prompts instead of using file refs. You skip T3R at milestones. Runtime bugs ship. |
| `references/progress-schema.md` | Writing wave entries, running T1 checks | Wave entries are freeform — T1 can't parse them, resume can't reconstruct state, the audit spine is broken. |
| `references/agent-guidelines.md` | Included in every builder agent prompt — tests, evidence, scope discipline | Builder agents mock their own code, modify test expectations to pass, write files outside their scope, create duplicates of existing utilities, and report "tests pass" with no evidence. |
| `references/brick-design.md` | Understanding what a brick is, how evidence works | You treat bricks as tasks instead of building blocks. Agents ship code that compiles but was never verified. Next wave builds on a lie. |
| `references/wave-planning.md` | Planning each wave — file conflict matrix, parallelism cap | 5 parallel agents modify the same file. Last writer wins. Earlier agents' work vanishes silently. Or: 8-way merge conflicts in package.json. |
| `references/failure-modes.md` | When a brick fails or a wave gate fails — recovery patterns | You force-resolve rebase conflicts, silently retry failed bricks, or skip the gate — each producing a documented class of sprint failure. |

### External skill dependencies

These skills are invoked during upstream planning phases. The sprint skill references them by name but does not contain their content.

| Skill | Phase | When |
|-------|-------|------|
| `software-design` | Design | Multi-component features — produces design.md with GUARANTEES/EXPECTS/FAILURE BEHAVIOR |
| `writing-implementation-plans` | Implementation Planning | Multi-file features (never skip) — produces plan.md |
| `brainstorming` | Brainstorming | Fuzzy ideas — refines direction before scoping |
| `writing-specs` | Requirements | Large features, external stakeholders — produces spec.md |
| `writing-qa-plan` | QA Planning | Multiple behaviors to verify — produces qa-plan.md |
| `writing-unit-tests` | Execution (via agent-guidelines) | Builder agents read this before writing tests |

---

## File Structure

```
tasks/
  <task-name>.tasks.json      # Brick definitions, deps, status
  <task-name>.decisions.md    # Decisions made during planning (READ-ONLY for agents)
  <task-name>.objective.md    # Sprint objective, context, goals
  <task-name>.context.md      # Optional — agent orientation (architecture, constraints, design refs)
  <task-name>.progress.md     # Append-only evidence log
  <task-name>.spec.md         # Optional — requirements spec
  <task-name>.qa-plan.md      # Optional — test cases from QA planning (feeds brick criteria + T3R audits)
```

**context.md** is optional. When present, referenced by path in every agent prompt. Use for the 20% agents always need: architecture overview, critical constraints, conventions, key file paths. Reference the 80% (full design docs, type specs) by path inside context.md — agents read those on demand.

**DESIGN.md** files sit alongside code in each module. They define component contracts, ownership boundaries, and architectural constraints. The orchestrator reads them at Step 1 (Load State). Bricks that violate DESIGN.md contracts fail review.

---

## Tasks Script

If a sprint tasks management script exists in the config root:

```bash
{CONFIG_ROOT}/skills/sprint/scripts/sprint_tasks.py <command> <tasks-file> [args]
```

| Command | Example |
|---------|---------|
| `list <file>` | Summary table. Add `--status pending` to filter. |
| `get <file> <id>` | Full brick JSON. |
| `ready <file>` | Next bricks (deps met, status pending). Add `--json` for parseable output. |
| `update <file> <id> --status passed` | Update any field. |
| `delete <file> <id>` | Remove a brick. |
| `graph <file>` | Dependency graph. |
| `init <file> --session <name> --objective <text>` | Create new tasks.json + companion files. |
| `worktree create <file> <id>` | Create isolated worktree for a brick (prints absolute path). |
| `worktree collect <file> <id>` | Rebase worktree branch onto HEAD and fast-forward. |
| `worktree cleanup <file> <id>` | Remove worktree directory and branch. |

**Adding bricks:** Edit `tasks.json` directly — append to the `bricks` array.
