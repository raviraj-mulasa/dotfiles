# Skills Index

Quick reference for all available skills. Each skill is a self-sufficient workflow an AI agent gets hired to do.

## Development Workflow

| Skill | What It Does |
|-------|-------------|
| `spec-driven-development` | End-to-end SDD pipeline: discover → spec → QA plan → design → plan → build → confirm |
| `writing-specs` | Capture requirements and acceptance criteria as the single source of truth |
| `writing-qa-plan` | Derive functional test cases from spec before design to verify user-facing behavior |
| `writing-implementation-plans` | Create backbone-only plans that serve both human review and agent execution |
| `debugging` | Systematic bug investigation via hypothesis → observation → confirmation → fix; no guessing |
| `sprint` | Multi-step feature implementation through brick decomposition and parallel agent execution |

## Code Quality & Review

| Skill | What It Does |
|-------|-------------|
| `code-quality` | Architecture review, simplification, SRP analysis, and implementation completeness checks |
| `writing-unit-tests` | Write unit tests that catch real bugs — test uncertainty, delete padding, validate mocks |

## Design & Planning

| Skill | What It Does |
|-------|-------------|
| `grill-me` | Interrogation session that turns fuzzy ideas into clear, structured requirements |
| `software-design` | Decompose software into components with explicit contracts and guarantees before implementation |
| `brainstorming` | Refine fuzzy ideas through structured dialogue into a clear direction |

## UX & Prompt Engineering

| Skill | What It Does |
|-------|-------------|
| `ux-design` | UX design principles, systems thinking, anti-patterns, and structured friction review |
| `prompt-engineering` | Review and improve AI agent prompts using field-tested principles |

## How to Use Skills

Reference a skill in your prompt to invoke its workflow:

- **With GitHub Copilot**: _"Read `skills/debugging/SKILL.md` and apply the debugging workflow to this error."_
- **With AGY**: Skills are auto-loaded based on their `description` trigger phrases.
- **With any AI**: Paste the SKILL.md content into context, or instruct the AI to read it.

> **Note:** `{CONFIG_ROOT}` refers to the root of this `ai-config-universal/` folder. Replace with the actual path when referencing skills in prompts.
