# dotfiles

Personal developer configuration and universal AI engineering suite.

---

## 🤖 AI Engineering Configuration (`ai-config-universal`)

This repository contains **`ai-config-universal`**, a vendor-neutral AI software engineering suite for:
- **VSCode + GitHub Copilot**
- **JetBrains IDEs + GitHub Copilot**
- **Claude Code**
- **Antigravity (AGY)**

It provides **13 specialized Agent Roles**, **13 Workflow Skills** built around **Spec-Driven Development (SDD)**, full tutorials, and automated deployment scripts.

### Quickstart

```bash
# 1. Audit your target repository for existing AI configurations
bash ai-config-universal/scripts/scan.sh /path/to/your/project

# 2. Preview what will be installed (dry run)
bash ai-config-universal/scripts/install.sh --dry-run /path/to/your/project

# 3. Install the AI configuration suite into your project
bash ai-config-universal/scripts/install.sh /path/to/your/project
```

### Documentation & Guides

- [**AI Config Universal Documentation**](./ai-config-universal/README.md) — Architecture, installation options, and platform details.
- [**Solo Developer Tutorial (TUTORIAL.md)**](./ai-config-universal/TUTORIAL.md) — Getting started guide and core workflows.
- [**Skills Index**](./ai-config-universal/skills/README.md) — Full list of all 13 skills.
- [**Tutorials Directory**](./ai-config-universal/tutorials/README.md) — In-depth guides for every skill and agent.
- [**Scaffolding Templates**](./ai-config-universal/templates/README.md) — `.editorconfig` and `.gitignore` templates for Python, Java, TypeScript, Rust, and Dart.

---

## 🔄 Updating Installed Projects

Pull the latest updates from this dotfiles repo and push them across all registered projects:

```bash
git pull
bash ai-config-universal/scripts/update.sh
```

---

## 🧪 Testing & Verification

Run the automated test suite to verify installation and conflict scenarios:

```bash
bash ai-config-universal/scripts/test-scenarios.sh
```

> **Note:** Scripts automatically resolve `CONFIG_ROOT` and `TEST_BASE` relative to their location. You can override them via environment variables if desired (e.g., `TEST_BASE=/tmp/sandbox bash ai-config-universal/scripts/test-scenarios.sh`).

