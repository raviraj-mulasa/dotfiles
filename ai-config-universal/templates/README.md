# Project Scaffolding Templates

Reference templates for quick project initialization and consistent editor configurations across languages.

---

## 📄 Available Templates

### 1. [`.editorconfig`](./.editorconfig)
Universal indentation and file formatting rules for modern IDEs and editors (VS Code, JetBrains, Android Studio, Neovim, Sublime):

| Language / File Type | Indentation | Notes |
|---|---|---|
| **Python** (`*.py`) | 4 spaces | PEP 8 compliant, `max_line_length = 88` |
| **Java / Kotlin / Gradle** (`*.java`, `*.kt`, `*.gradle`) | 4 spaces | Standard JVM formatting |
| **Rust** (`*.rs`) | 4 spaces | Standard Cargo/Rustfmt convention |
| **TypeScript / JavaScript** (`*.ts`, `*.tsx`, `*.js`, `*.jsx`) | 2 spaces | Standard Prettier/ESLint convention |
| **Dart / Flutter** (`*.dart`) | 2 spaces | Standard `dart format` convention |
| **Configs / Markup** (`*.json`, `*.yaml`, `*.toml`, `*.xml`) | 2 spaces | UTF-8, LF endings, trimmed trailing whitespace |
| **Markdown** (`*.md`) | 2 spaces | Trailing whitespace preserved for line breaks |
| **Makefiles** (`Makefile`) | Tab | Required for make rules |

---

### 2. [`.gitignore`](./.gitignore)
Comprehensive, multi-language `.gitignore` template preconfigured for:
- **Languages**: Python (pycache, venvs, pytest, mypy), Java (Maven target, Gradle build, classes), TypeScript/JavaScript (node_modules, dist, .turbo), Rust (target), Dart/Flutter (.dart_tool, pub, build).
- **IDEs**: VS Code, JetBrains (IntelliJ, PyCharm, WebStorm, Android Studio), Xcode.
- **Operating Systems**: macOS (`.DS_Store`), Windows (`Thumbs.db`), Linux.
- **AI / SDD Pipeline**: Automatically excludes ephemeral task plans (`tasks/*.plan.md`, `tasks/*.qa-plan.md`, `tasks/*.design.md`) and backups (`.ai-config-backup/`).

---

## 🚀 Quick Usage

Copy directly into any target project root:

```bash
# Copy .editorconfig
cp ai-config-universal/templates/.editorconfig /path/to/project/.editorconfig

# Copy .gitignore (or merge)
cp ai-config-universal/templates/.gitignore /path/to/project/.gitignore
```
