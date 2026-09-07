#!/usr/bin/env bash
# =============================================================================
# ai-config-universal — dotfiles installer
#
# Copies AI engineering config (Copilot, Claude Code, AGY, SDD scaffold)
# into any target project. Safe to re-run — skips existing files by default.
#
# Usage:
#   ./scripts/install.sh /path/to/your/project
#   ./scripts/install.sh --force /path/to/your/project   # overwrite existing
#   ./scripts/install.sh --dry-run /path/to/your/project # preview only
#   ./scripts/install.sh --help
#
# After installing, each project path is saved to ~/.ai-config-projects
# so that scripts/update.sh can push changes to all registered projects at once.
#
# Why copy and not symlink?
#   Symlinks break on other machines, in CI, and when team members clone.
#   Copies are self-contained — the project owns its config.
#   To update all projects at once: git pull, then run scripts/update.sh
# =============================================================================

set -euo pipefail

# ── Resolve config root (the ai-config-universal/ folder) ────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="${CONFIG_ROOT:-$(dirname "$SCRIPT_DIR")}"

# ── Project registry — machine-local list of installed project paths ──────────
REGISTRY="${HOME}/.ai-config-projects"

# ── Flags ─────────────────────────────────────────────────────────────────────
FORCE=false
BACKUP=false
DRY_RUN=false
TARGET_DIR=""

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}  ✓${NC} $1"; }
info() { echo -e "${BLUE}  →${NC} $1"; }
warn() { echo -e "${YELLOW}  ⚠${NC} $1"; }
err()  { echo -e "${RED}  ✗${NC} $1"; exit 1; }
dry()  { echo -e "${YELLOW}  [dry]${NC} $1"; }

# ── Parse arguments ───────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --force)    FORCE=true ;;
    --backup)   BACKUP=true ;;
    --dry-run)  DRY_RUN=true ;;
    --help|-h)
      cat <<EOF

Usage: install.sh [options] <target-project-path>

Options:
  --dry-run   Preview what would be copied without making any changes
  --force     Overwrite files that already exist in the target project
  --backup    Create a timestamped backup in .ai-config-backup/ before overwriting
  --help      Show this help

Example:
  install.sh ~/code/my-app
  install.sh --dry-run ~/code/my-app
  install.sh --force ~/code/my-app
  install.sh --backup --force ~/code/my-app

What gets installed:
  .github/copilot-instructions.md  → GitHub Copilot (VSCode + JetBrains)
  AGENT.md                         → Universal AI identity & principles
  CLAUDE.md                        → Claude Code (auto-loaded on startup)
  .agents/                         → AGY (Antigravity, project-scoped)
  agents/                          → Agent role definitions (all tools)
  skills/                          → Skill workflows (all tools)
  output-styles/                   → Anti-litter discipline (Claude Code)
  .editorconfig                    → Multi-language formatting rules
  .gitignore                       → Multi-language ignore rules & SDD patterns
  docs/specs/  (scaffold)          → Where specs live (SDD pipeline)
  tasks/       (scaffold)          → Where plans/QA plans live (SDD pipeline)

EOF
      exit 0
      ;;
    -*) err "Unknown option: $arg. Use --help for usage." ;;
    *)  TARGET_DIR="$arg" ;;
  esac
done

[[ -n "$TARGET_DIR" ]] || err "No target project path given. Usage: install.sh <path>"
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || err "Target directory not found: $TARGET_DIR"
[[ "$TARGET_DIR" != "$CONFIG_ROOT" ]] || err "Cannot install into the config repo itself."

BACKUP_DIR="$TARGET_DIR/.ai-config-backup/$(date +%Y%m%d_%H%M%S)"

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       ai-config-universal  ·  installer          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo "  Source : $CONFIG_ROOT"
echo "  Target : $TARGET_DIR"
$FORCE   && echo "  Mode   : COPY (overwrite existing)"
$FORCE   || echo "  Mode   : COPY (skip existing)"
$BACKUP  && echo "  Backup : YES → $BACKUP_DIR"
$DRY_RUN && echo "  Dry run: YES — no files will be changed"
echo ""

# ── Copy helper ───────────────────────────────────────────────────────────────
# copy_item <src> <dst> <label>
copy_item() {
  local src="$1" dst="$2" label="$3"
  local dst_dir; dst_dir="$(dirname "$dst")"

  if $DRY_RUN; then
    dry "copy → $dst"
    return
  fi

  mkdir -p "$dst_dir"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if $FORCE; then
      if $BACKUP; then
        local rel_path="${dst#$TARGET_DIR/}"
        local bkp_target="$BACKUP_DIR/$rel_path"
        mkdir -p "$(dirname "$bkp_target")"
        cp -r "$dst" "$bkp_target"
        info "Backed up existing $label → .ai-config-backup/"
      fi
      rm -rf "$dst"
      if [[ -d "$src" ]]; then
        cp -r "$src" "$dst"
      else
        cp "$src" "$dst"
      fi
      ok "$label"
      return
    else
      if [[ -d "$src" && -d "$dst" ]]; then
        # Merge directory contents without overwriting existing files
        cp -rn "$src/"* "$dst/" 2>/dev/null || true
        ok "$label (merged missing files)"
        return
      else
        warn "$label already exists — skipping (use --force to overwrite)"
        return
      fi
    fi
  fi

  if [[ -d "$src" ]]; then
    cp -r "$src" "$dst"
  else
    cp "$src" "$dst"
  fi
  ok "$label"
}

# ── scaffold helper (create empty dirs) ──────────────────────────────────────
scaffold_dir() {
  local dir="$1" label="$2"
  if $DRY_RUN; then
    dry "create dir → $dir/"
    return
  fi
  if [[ -d "$dir" ]]; then
    ok "$label (already exists)"
  else
    mkdir -p "$dir"
    touch "$dir/.gitkeep"
    ok "$label (created)"
  fi
}

# ═════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Universal Principles & GitHub Copilot
# ═════════════════════════════════════════════════════════════════════════════
echo "── 1 of 5 · GitHub Copilot & Principles ─────────────────────────"
copy_item \
  "$CONFIG_ROOT/.github/copilot-instructions.md" \
  "$TARGET_DIR/.github/copilot-instructions.md" \
  ".github/copilot-instructions.md"

copy_item \
  "$CONFIG_ROOT/AGENT.md" \
  "$TARGET_DIR/AGENT.md" \
  "AGENT.md"

# ═════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Claude Code & Output Styles
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo "── 2 of 5 · Claude Code & Output Styles ─────────────────────────"
copy_item \
  "$CONFIG_ROOT/CLAUDE.md" \
  "$TARGET_DIR/CLAUDE.md" \
  "CLAUDE.md"

copy_item \
  "$CONFIG_ROOT/output-styles" \
  "$TARGET_DIR/output-styles" \
  "output-styles/"

# ═════════════════════════════════════════════════════════════════════════════
# SECTION 3 — AGY (Antigravity)
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo "── 3 of 5 · AGY (Antigravity) ───────────────────────────────────"
# Copy .agents/ but resolve symlinks inside it so target gets real files
if $DRY_RUN; then
  dry "copy → $TARGET_DIR/.agents/"
else
  mkdir -p "$TARGET_DIR/.agents/rules"
  copy_item \
    "$CONFIG_ROOT/.agents/rules/engineering-principles.md" \
    "$TARGET_DIR/.agents/rules/engineering-principles.md" \
    ".agents/rules/engineering-principles.md"
  copy_item \
    "$CONFIG_ROOT/.agents/README.md" \
    "$TARGET_DIR/.agents/README.md" \
    ".agents/README.md"
  ok ".agents/ (structure created)"
fi

# ═════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Shared agents/ and skills/
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo "── 4 of 5 · Agents & Skills (shared by all tools) ──────────────"
copy_item \
  "$CONFIG_ROOT/agents" \
  "$TARGET_DIR/agents" \
  "agents/"

copy_item \
  "$CONFIG_ROOT/skills" \
  "$TARGET_DIR/skills" \
  "skills/"

# Wire up .agents/ symlinks to the copied dirs (internal only, within project)
if ! $DRY_RUN; then
  # .agents/skills and .agents/agents should point to the project-local copies
  ln -sfn "../skills" "$TARGET_DIR/.agents/skills"
  ln -sfn "../agents" "$TARGET_DIR/.agents/agents"
  ok ".agents/skills → ../skills (internal link)"
  ok ".agents/agents → ../agents (internal link)"
fi

# ═════════════════════════════════════════════════════════════════════════════
# SECTION 5 — SDD Pipeline & Scaffolding (.editorconfig, .gitignore)
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo "── 5 of 5 · SDD Pipeline & Scaffolding ─────────────────────────"
scaffold_dir "$TARGET_DIR/docs/specs" "docs/specs/"
scaffold_dir "$TARGET_DIR/tasks"      "tasks/"

# Copy .editorconfig if template exists
if [[ -f "$CONFIG_ROOT/templates/.editorconfig" ]]; then
  copy_item \
    "$CONFIG_ROOT/templates/.editorconfig" \
    "$TARGET_DIR/.editorconfig" \
    ".editorconfig"
fi

# Scaffolding .gitignore
GITIGNORE="$TARGET_DIR/.gitignore"
if [[ ! -e "$GITIGNORE" && -f "$CONFIG_ROOT/templates/.gitignore" ]]; then
  copy_item \
    "$CONFIG_ROOT/templates/.gitignore" \
    "$TARGET_DIR/.gitignore" \
    ".gitignore (scaffolded)"
else
  # Append SDD working-doc patterns if .gitignore exists
  declare -a PATTERNS=(
    ""
    "# ai-config-universal — SDD working documents (ephemeral, not source of truth)"
    "tasks/*.plan.md"
    "tasks/*.qa-plan.md"
    "tasks/*.design.md"
    "tasks/*.requirements.md"
    "tasks/codebase-orientation.md"
    ".ai-config-backup/"
  )
  if $DRY_RUN; then
    dry "append SDD patterns to .gitignore"
  else
    for pattern in "${PATTERNS[@]}"; do
      if [[ -z "$pattern" ]] || ! grep -qF "$pattern" "$GITIGNORE" 2>/dev/null; then
        echo "$pattern" >> "$GITIGNORE"
      fi
    done
    ok ".gitignore — SDD patterns verified"
  fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# Summary
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Done!                                           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo "  Installed into: $TARGET_DIR"
echo ""
echo "  ┌─────────────────────────────────────────────────────┐
  │  What's installed          What it enables          │
  ├─────────────────────────────────────────────────────┤
  │  .github/copilot-*         GitHub Copilot           │
  │  AGENT.md                  Universal AI Principles  │
  │  CLAUDE.md                 Claude Code              │
  │  output-styles/            Anti-litter Discipline   │
  │  .agents/                  AGY (Antigravity)        │
  │  agents/ + skills/         All three tools          │
  │  .editorconfig             Code Formatting Rules    │
  │  .gitignore                Ignore & SDD Rules       │
  │  docs/specs/               SDD — commit specs here  │
  │  tasks/                    SDD — gitignored plans   │
  └─────────────────────────────────────────────────────┘"
echo ""

# ── Register this project so update.sh can find it later ─────────────────────
if ! $DRY_RUN; then
  if touch "$REGISTRY" 2>/dev/null; then
    if ! grep -qF "$TARGET_DIR" "$REGISTRY" 2>/dev/null; then
      echo "$TARGET_DIR" >> "$REGISTRY"
      echo "  Registered in : $REGISTRY"
      echo "  (run scripts/update.sh to push future config changes to all projects)"
    else
      echo "  Already registered in: $REGISTRY"
    fi
  else
    warn "Could not write to $REGISTRY (sandbox or permission constraint)"
    echo "  You can manually add '$TARGET_DIR' to $REGISTRY"
  fi
fi

echo ""
echo "  To update later:"
echo "    git pull                          # update dotfiles"
echo "    bash scripts/update.sh            # push to all registered projects"
echo "    bash scripts/update.sh --list     # see all registered projects"
echo ""
echo "  Try it now:"
echo "    Claude Code → 'Use the spec-driven-development skill'"
echo "    Copilot     → '@workspace Read skills/debugging/SKILL.md'"
echo "    AGY         → 'Debug this error...' (auto-triggered)"
echo ""

