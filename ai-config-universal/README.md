# ai-config-universal

> **New here?** Start with [TUTORIAL.md](./TUTORIAL.md) — a practical guide for solo developers that tells you which 5 tools to use first and exactly how to invoke them.

Vendor-neutral AI engineering configuration. Works with:

- **VSCode + GitHub Copilot**
- **JetBrains IDEs + GitHub Copilot**
- **Claude Code**
- **Antigravity (AGY)**

This config is derived from a Claude-specific setup and rewritten to be tool-agnostic: no references to specific AI model names, no vendor-specific CLI paths, no hardcoded home directories.

---

## The SDD Blueprint

This config is built around **Spec-Driven Development (SDD)** — a pipeline discipline where the spec is the single source of truth. Every other tool in this config plugs into a specific stage of this pipeline.

```
Stage 0: Discover          grill-me skill
         ↓
Stage 1: Specify           writing-specs skill       → docs/specs/feature.spec.md
         ↓
Stage 2: QA Plan           writing-qa-plan skill     → tasks/feature.qa-plan.md
         ↓
Stage 3: Design            software-design skill     → tasks/feature.design.md
         ↓
Stage 4: Plan              writing-implementation-plans → tasks/feature.plan.md
         ↓
Stage 5: Build             engineer / fast-worker agents
         ↓
Stage 6: Confirm           implementation-reviewer + code-reviewer + security-reviewer
         ↓
Stage 7: Maintain          writing-specs skill (maintain mode)
```

**Scale to your feature size:**

| Feature | Minimum pipeline |
|---|---|
| Large (6+ files, complex behavior) | All 7 stages |
| Medium (3-5 files) | Stages 1 → 2 → 4 → 5 → 6 |
| Small (1-2 files, clear behavior) | Stage 1 → 5 → 6 |
| Bug fix | No pipeline — just fix and review |

> See `skills/spec-driven-development/SKILL.md` for the full pipeline with gates, traceability chain, and anti-patterns. Tutorial: `tutorials/skills/spec-driven-development.md`.

---

## Adding to a Repository

Use the install script. It **copies** files into your project so each repo is self-contained — no symlinks, no external dependencies, works on any machine.

```bash
# 1. Pre-audit: check for existing configs, conflicts, or alternate locations
bash scripts/scan.sh /path/to/your/project

# 2. Preview what will be installed (dry run)
bash scripts/install.sh --dry-run /path/to/your/project

# 3. Install fresh (skips existing files by default)
bash scripts/install.sh /path/to/your/project

# 4. If conflicts exist: backup existing configs and overwrite
bash scripts/install.sh --backup --force /path/to/your/project
```

**What gets copied into your project:**

```
your-project/
├── .github/
│   └── copilot-instructions.md   → GitHub Copilot (VSCode + JetBrains)
├── .agents/
│   └── rules/engineering-principles.md  → AGY (always-on rules)
├── agents/                       → Agent roles (all tools)
├── skills/                       → Skill workflows (all tools)
├── CLAUDE.md                     → Claude Code (auto-loaded on startup)
├── .editorconfig                 → Formatting rules for Python, Java, TS, Rust, Dart
├── .gitignore                    → Ignore rules for 5+ languages + SDD patterns
├── docs/specs/                   → Commit your specs here (SDD pipeline)
└── tasks/                        → Gitignored SDD working docs
```

**To update later:** pull this dotfiles repo, then run `update.sh` — it pushes to every project automatically.

```bash
git pull                       # get latest config from dotfiles repo
bash scripts/update.sh         # push updates to ALL registered projects
bash scripts/update.sh --list  # see which projects are registered
bash scripts/update.sh --dry-run  # preview changes before applying
```

### How the update registry works

Every time you run `install.sh`, it records the project path to `~/.ai-config-projects` on your machine:

```
# ~/.ai-config-projects
/Users/you/code/project-alpha
/Users/you/code/project-beta
/Users/you/code/project-gamma
```

`update.sh` reads this file and runs `install.sh --force` on each path — overwriting only the AI config files, leaving your project code untouched.

```bash
bash scripts/update.sh --remove /path/to/old-project  # stop updating a project
```

### What gets overwritten vs preserved on update

| File | On update |
|---|---|
| `CLAUDE.md` | ✅ Overwritten (latest config) |
| `.github/copilot-instructions.md` | ✅ Overwritten |
| `.agents/rules/engineering-principles.md` | ✅ Overwritten |
| `agents/` + `skills/` | ✅ Overwritten |
| `docs/specs/*.spec.md` | ❌ Never touched — your specs |
| `tasks/*.plan.md` | ❌ Never touched — your plans |
| Your source code | ❌ Never touched |

### Why copy and not symlink?

Symlinks only work on the machine where both the source and destination paths exist. Copy is correct for a dotfiles repo because:

- ✅ Clone the dotfiles on any machine, run install, it works
- ✅ Team members who clone your project get the actual files
- ✅ Moving or deleting the dotfiles repo doesn't break anything
- ✅ Files are committed to each project's git — portable and self-contained
- ❌ Symlinks break on other machines, in CI, and when paths change

### What goes into .gitignore

The install script appends these automatically:

```gitignore
# SDD working documents — ephemeral, not source of truth
tasks/*.plan.md
tasks/*.qa-plan.md
tasks/*.design.md
tasks/*.requirements.md
tasks/codebase-orientation.md
```

`docs/specs/` is **not** gitignored — specs are the source of truth and should be committed.

---

## Folder Structure

```
ai-config-universal/
├── README.md                         # This file
├── AGENT.md                          # Universal AI identity & engineering principles
├── CLAUDE.md                         # Claude Code entry point (auto-loaded by Claude Code)
├── TUTORIAL.md                       # Solo developer guide: which tools to use and when
├── plan_guide.md                     # Implementation plan format guide
│
├── .github/
│   └── copilot-instructions.md       # GitHub Copilot workspace instructions
│
├── .agents/                          # AGY project-scoped config
│   ├── rules/engineering-principles.md
│   ├── skills → ../skills
│   └── agents → ../agents
│
├── agents/                           # Sub-agent role definitions (13 agents)
│   ├── code-reviewer.md
│   ├── codebase-explorer.md
│   ├── commit-curator.md
│   ├── engineer.md
│   ├── fast-worker.md
│   ├── implementation-reviewer.md
│   ├── minion.md
│   ├── pr-description-writer.md
│   ├── qa-dev.md
│   ├── security-reviewer.md
│   ├── sprint-dev.md
│   ├── ux-reviewer.md
│   └── visual-qa-lead.md
│
├── output-styles/
│   └── do-not-litter.md              # Anti-summary-spam discipline
│
├── templates/                        # Scaffolding templates (.editorconfig, .gitignore)
│   ├── .editorconfig                 # Multi-language formatting (Python, Java, TS, Rust, Dart)
│   ├── .gitignore                    # Multi-language ignore rules + SDD patterns
│   └── README.md
│
└── skills/                           # Reusable skill prompts (13 skills)
    ├── README.md
    ├── brainstorming/SKILL.md
    ├── code-quality/SKILL.md
    ├── debugging/SKILL.md
    ├── grill-me/SKILL.md
    ├── prompt-engineering/SKILL.md
    ├── software-design/
    │   ├── SKILL.md
    │   └── references/design-smells.md
    ├── spec-driven-development/SKILL.md
    ├── sprint/SKILL.md
    ├── ux-design/SKILL.md
    ├── writing-implementation-plans/SKILL.md
    ├── writing-qa-plan/SKILL.md
    ├── writing-specs/SKILL.md
    └── writing-unit-tests/SKILL.md
```

---

## Setup by Platform

### VSCode + GitHub Copilot

1. Copy `.github/copilot-instructions.md` into your project's `.github/` folder.
2. Copilot Chat will automatically pick up this file as workspace-level instructions.
3. For agent roles, reference them inline in Copilot Chat: _"Act as the code-reviewer agent defined in `agents/code-reviewer.md`."_
4. Or use Copilot's `@workspace` to ask it to read a skill: _"Read `skills/debugging/SKILL.md` and apply the debugging workflow to this error."_

> **Tip:** Commit `.github/copilot-instructions.md` to your project repo so every team member gets the same AI context automatically.

### JetBrains IDEs + GitHub Copilot

1. Same `.github/copilot-instructions.md` file is read by GitHub Copilot in JetBrains (IntelliJ, WebStorm, PyCharm, etc.).
2. In Copilot Chat within JetBrains, reference skill files the same way as VSCode.
3. You can also use JetBrains AI Assistant with this config by copying `AGENT.md` content into the AI Assistant system prompt settings under **Settings → Tools → AI Assistant → System Prompt**.

### Claude Code

Claude Code automatically reads `CLAUDE.md` from your project root (and parent directories up to `~/`).

**Option A — Per project (recommended):**
```bash
# Copy CLAUDE.md to your project root
cp /path/to/ai-config-universal/CLAUDE.md ./CLAUDE.md

# Copy skills and agents alongside it
cp -r /path/to/ai-config-universal/skills ./skills
cp -r /path/to/ai-config-universal/agents ./agents
```

**Option B — Global (applies to all Claude Code sessions):**
```bash
# Place CLAUDE.md in your home ~/.claude/ directory
mkdir -p ~/.claude
cp /path/to/ai-config-universal/CLAUDE.md ~/.claude/CLAUDE.md
cp -r /path/to/ai-config-universal/skills ~/.claude/skills
cp -r /path/to/ai-config-universal/agents ~/.claude/agents
```

**Option C — Symlink (keeps it in sync with this repo):**
```bash
ln -s /path/to/ai-config-universal/CLAUDE.md ~/.claude/CLAUDE.md
```

Once in place, Claude Code will load `CLAUDE.md` at the start of every session. The skills and agent files are referenced by relative path from `CLAUDE.md` so Claude Code can read them on demand.

> **Tip:** The `agents/*.md` files in this config use a `tier:` field instead of Claude-specific `model:` frontmatter, so they work as reference docs for any Claude Code sub-agent invocation.

### Antigravity (AGY) — Project-Specific

AGY auto-discovers a `.agents/` folder at your project root and loads skills and rules from it. This means you can scope the config **per project** by checking `.agents/` into your repo — no global install needed.

This repo ships a ready-to-use `.agents/` folder. To activate it for a project:

**Option A — Copy into your project (commit to VCS):**
```bash
cp -r /path/to/ai-config-universal/.agents  your-project/.agents
```
AGY will auto-discover `.agents/` when you open the project. Your whole team gets the same config because it lives in the repo.

**Option B — Symlink from this repo (stays in sync):**
```bash
ln -s /path/to/dotfiles/ai-config-universal/.agents  your-project/.agents
```

**What's inside `.agents/`:**

```
.agents/
├── rules/
│   └── engineering-principles.md   ← always-on rules (loaded every session)
├── skills → ../skills              ← symlink to skills/ folder
└── agents → ../agents              ← symlink to agents/ folder
```

AGY loads `rules/engineering-principles.md` automatically on every session (it has `trigger: always_on`). Skills are loaded on-demand — only when you ask AGY to use one.

**Loading priority:** Project `.agents/` overrides global `~/.gemini/config/`. So a per-project `.agents/` will always take precedence.

---

## Key Concepts

### Agent Tiers

Rather than naming specific AI models, this config uses **capability tiers**:

| Tier | Description | Use for |
|------|-------------|---------|
| `fast-worker` | Lightweight, cheap, literal | File searches, grep, command runs, log analysis, high-volume text tasks |
| `engineer` | Reasoning-capable, slower | Code review, implementation, investigation, architecture, planning |

When using with Copilot or other tools, map these tiers to the AI options available in your IDE.

### Skills

Skills are reusable prompt workflows. Reference them by saying:
> _"Follow the workflow in `skills/debugging/SKILL.md`"_
> _"Apply the `skills/writing-unit-tests/SKILL.md` principles to these tests"_

### Agents

Agent files define specialized roles. Invoke them by including their content as context:
> _"You are the code-reviewer agent. Read `agents/code-reviewer.md` for your methodology."_

---

## Path Resolution & Environment Variables

All scripts and configurations are designed to be fully self-contained and auto-resolving:

- **`CONFIG_ROOT` (Auto-detected)**: All scripts automatically resolve the `ai-config-universal` root directory relative to their location (`$(dirname "$SCRIPT_DIR")`). If needed, you can override this by setting the `CONFIG_ROOT` environment variable:
  ```bash
  CONFIG_ROOT=/path/to/custom/ai-config-universal bash scripts/install.sh /path/to/project
  ```
- **`TEST_BASE` (Auto-detected)**: `scripts/test-scenarios.sh` defaults to creating a sandbox test suite at `../../test-sandbox-suite`. You can override this to any temporary path:
  ```bash
  TEST_BASE=/tmp/my-test-sandbox bash scripts/test-scenarios.sh
  ```
- **Prompt Placeholders (`{CONFIG_ROOT}`)**: Within skill documents and prompt references, `{CONFIG_ROOT}` represents the root of this configuration. In target projects where files are copied directly, relative paths (e.g., `skills/debugging/SKILL.md`) work out of the box.

---

## What Was Removed vs. Original

This config strips out:
- Claude-specific model names (`opus`, `haiku`, `sonnet` as model identifiers)
- `~/.claude/` path references → replaced with relative `{CONFIG_ROOT}/` references
- `CMUX_*` environment variables (Claude MUX-specific)
- Personal names in core prompts
- Claude agent YAML frontmatter (`model:`, `color:`) → replaced with generic role descriptions

The engineering content — debugging workflows, code quality principles, test discipline, sprint process, UX review methodology — is unchanged.
