#!/usr/bin/env bash
# =============================================================================
# ai-config-universal — project scanner
#
# Audits a target project for existing AI config files before install/update.
# Detects: same name same location, same name diff location, different name
# same purpose, partial installs, and customized content.
#
# Usage:
#   ./scripts/scan.sh /path/to/your/project
#   ./scripts/scan.sh --json /path/to/your/project   # machine-readable output
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="${CONFIG_ROOT:-$(dirname "$SCRIPT_DIR")}"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'
BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
ok()     { echo -e "  ${GREEN}✓ CLEAN${NC}    $1"; }
conflict(){ echo -e "  ${RED}✗ CONFLICT${NC} $1"; }
warn()   { echo -e "  ${YELLOW}⚠ WARN${NC}    $1"; }
info()   { echo -e "  ${BLUE}ℹ INFO${NC}     $1"; }
dim()    { echo -e "  ${DIM}$1${NC}"; }

JSON_MODE=false
TARGET_DIR=""

for arg in "$@"; do
  case "$arg" in
    --json)   JSON_MODE=true ;;
    --help|-h)
      cat <<EOF
Usage: scan.sh [--json] <target-project-path>

Scans a project for existing AI config files and reports conflicts.

Output codes per item:
  ✓ CLEAN     File is absent — install.sh will create it fresh
  ✗ CONFLICT  File exists with different content — needs decision
  ⚠ WARN      Alternate location or name found for the same purpose
  ℹ INFO      File exists and matches our version exactly

Run this before install.sh or update.sh to understand what will change.
EOF
      exit 0
      ;;
    -*) echo "Unknown option: $arg"; exit 1 ;;
    *)  TARGET_DIR="$arg" ;;
  esac
done

[[ -n "$TARGET_DIR" ]] || { echo "Usage: scan.sh <target-project-path>"; exit 1; }
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || { echo "Directory not found: $TARGET_DIR"; exit 1; }

# ── Helpers ───────────────────────────────────────────────────────────────────

# Returns: "absent" | "identical" | "customized" | "unknown"
file_status() {
  local target="$1" source="$2"
  if [[ ! -e "$target" ]]; then
    echo "absent"
  elif [[ -f "$source" ]] && diff -q "$target" "$source" > /dev/null 2>&1; then
    echo "identical"
  else
    echo "customized"
  fi
}

# Count lines that differ between two files
diff_lines() {
  local a="$1" b="$2"
  diff "$a" "$b" 2>/dev/null | grep -c '^[<>]' || echo "?"
}

CONFLICTS=0
WARNINGS=0

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}ai-config-universal · Project Scanner${NC}"
echo "  Scanning: $TARGET_DIR"
echo ""

# ═════════════════════════════════════════════════════════════════════════════
# 1. CLAUDE CODE — CLAUDE.md
# ═════════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}── Claude Code ──────────────────────────────────────────────────${NC}"

CANONICAL="$TARGET_DIR/CLAUDE.md"
STATUS=$(file_status "$CANONICAL" "$CONFIG_ROOT/CLAUDE.md")

case "$STATUS" in
  absent)     ok "CLAUDE.md — not present, will be created" ;;
  identical)  info "CLAUDE.md — exists, matches our version exactly" ;;
  customized)
    LINES=$(diff_lines "$CANONICAL" "$CONFIG_ROOT/CLAUDE.md" 2>/dev/null || echo "?")
    conflict "CLAUDE.md — exists with custom content (~$LINES differing lines)"
    dim "  Decision needed: merge | replace | skip"
    dim "  Backup: install.sh --force creates .ai-config-backup/ before overwriting"
    (( CONFLICTS++ ))
    ;;
esac

# Check alternate locations/names for same purpose
declare -a CLAUDE_ALTERNATES=(
  "claude.md"
  "AGENT.md"
  "agent.md"
  ".claude/CLAUDE.md"
  "src/CLAUDE.md"
  "docs/CLAUDE.md"
)
for alt in "${CLAUDE_ALTERNATES[@]}"; do
  if [[ -e "$TARGET_DIR/$alt" ]]; then
    warn "Alternate Claude config found: $alt (same purpose as CLAUDE.md)"
    dim "  Both may load — check which tool picks up which file"
    (( WARNINGS++ ))
  fi
done

# ═════════════════════════════════════════════════════════════════════════════
# 2. GITHUB COPILOT — copilot-instructions.md
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}── GitHub Copilot ───────────────────────────────────────────────${NC}"

CANONICAL="$TARGET_DIR/.github/copilot-instructions.md"
STATUS=$(file_status "$CANONICAL" "$CONFIG_ROOT/.github/copilot-instructions.md")

case "$STATUS" in
  absent)     ok ".github/copilot-instructions.md — not present, will be created" ;;
  identical)  info ".github/copilot-instructions.md — matches our version" ;;
  customized)
    LINES=$(diff_lines "$CANONICAL" "$CONFIG_ROOT/.github/copilot-instructions.md" 2>/dev/null || echo "?")
    conflict ".github/copilot-instructions.md — custom content (~$LINES differing lines)"
    dim "  Decision needed: merge | replace | skip"
    (( CONFLICTS++ ))
    ;;
esac

declare -a COPILOT_ALTERNATES=(
  ".github/copilot.md"
  ".github/instructions/copilot.md"
  ".github/instructions.md"
  ".copilot-instructions"
  "copilot-instructions.md"
)
for alt in "${COPILOT_ALTERNATES[@]}"; do
  if [[ -e "$TARGET_DIR/$alt" ]]; then
    warn "Alternate Copilot config found: $alt"
    dim "  Copilot may read this instead of .github/copilot-instructions.md"
    (( WARNINGS++ ))
  fi
done

# ═════════════════════════════════════════════════════════════════════════════
# 3. AGY — .agents/ folder
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}── AGY (Antigravity) ────────────────────────────────────────────${NC}"

if [[ -d "$TARGET_DIR/.agents" ]]; then
  RULES_FILE="$TARGET_DIR/.agents/rules/engineering-principles.md"
  if [[ -f "$RULES_FILE" ]]; then
    STATUS=$(file_status "$RULES_FILE" "$CONFIG_ROOT/.agents/rules/engineering-principles.md")
    case "$STATUS" in
      identical)  info ".agents/ — exists, rules match our version" ;;
      customized)
        LINES=$(diff_lines "$RULES_FILE" "$CONFIG_ROOT/.agents/rules/engineering-principles.md" 2>/dev/null || echo "?")
        conflict ".agents/rules/engineering-principles.md — custom content (~$LINES differing lines)"
        dim "  Your custom always-on rules will be overwritten by --force"
        (( CONFLICTS++ ))
        ;;
    esac
  else
    warn ".agents/ exists but rules/engineering-principles.md is missing"
    dim "  Partial AGY setup — install.sh will add the missing file"
    (( WARNINGS++ ))
  fi
else
  ok ".agents/ — not present, will be created"
fi

# AGY alternate folder names
declare -a AGY_ALTERNATES=(".agent" "_agents" "_agent")
for alt in "${AGY_ALTERNATES[@]}"; do
  if [[ -d "$TARGET_DIR/$alt" ]]; then
    warn "Alternate AGY folder found: $alt/ (AGY also discovers this name)"
    dim "  AGY may load BOTH — consolidate to .agents/ or remove $alt/"
    (( WARNINGS++ ))
  fi
done

# ═════════════════════════════════════════════════════════════════════════════
# 4. SKILLS — skills/ folder
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}── Skills ───────────────────────────────────────────────────────${NC}"

if [[ -d "$TARGET_DIR/skills" ]]; then
  # Count matching, missing, extra skills
  OUR_SKILLS=()
  while IFS= read -r -d '' d; do
    skill=$(basename "$d")
    OUR_SKILLS+=("$skill")
  done < <(find "$CONFIG_ROOT/skills" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)

  MATCHING=0; MISSING=0; CUSTOMIZED=0; EXTRA=0

  for skill in "${OUR_SKILLS[@]}"; do
    if [[ ! -d "$TARGET_DIR/skills/$skill" ]]; then
      (( MISSING++ ))
    elif diff -rq --exclude="*.pyc" \
        "$CONFIG_ROOT/skills/$skill" "$TARGET_DIR/skills/$skill" > /dev/null 2>&1; then
      (( MATCHING++ ))
    else
      (( CUSTOMIZED++ ))
    fi
  done

  # Skills in target not in ours
  while IFS= read -r -d '' d; do
    skill=$(basename "$d")
    found=false
    for s in "${OUR_SKILLS[@]}"; do [[ "$s" == "$skill" ]] && found=true && break; done
    $found || (( EXTRA++ ))
  done < <(find "$TARGET_DIR/skills" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)

  [[ $MATCHING -gt 0 ]]   && info "skills/ — $MATCHING skill(s) match our version"
  [[ $MISSING -gt 0 ]]    && warn "skills/ — $MISSING skill(s) from our set are missing"
  [[ $CUSTOMIZED -gt 0 ]] && { conflict "skills/ — $CUSTOMIZED skill(s) have custom content"; (( CONFLICTS++ )); }
  [[ $EXTRA -gt 0 ]]      && info "skills/ — $EXTRA extra skill(s) not in our set (will be preserved)"

  # Alternate skill locations
  declare -a SKILL_ALTERNATES=(".skills" "prompts" "ai-skills" "llm-skills" ".prompts")
  for alt in "${SKILL_ALTERNATES[@]}"; do
    if [[ -d "$TARGET_DIR/$alt" ]]; then
      warn "Alternate skills folder found: $alt/ — may conflict with skills/"
      (( WARNINGS++ ))
    fi
  done
else
  ok "skills/ — not present, will be created"
fi

# ═════════════════════════════════════════════════════════════════════════════
# 5. AGENTS — agents/ folder
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}── Agents ───────────────────────────────────────────────────────${NC}"

if [[ -d "$TARGET_DIR/agents" ]]; then
  OUR_AGENTS=()
  while IFS= read -r -d '' f; do
    OUR_AGENTS+=("$(basename "$f")")
  done < <(find "$CONFIG_ROOT/agents" -maxdepth 1 -name "*.md" -print0 2>/dev/null)

  MATCHING=0; CUSTOMIZED=0; EXTRA=0

  for agent in "${OUR_AGENTS[@]}"; do
    if [[ ! -f "$TARGET_DIR/agents/$agent" ]]; then
      : # missing — silent, will be added
    elif diff -q "$CONFIG_ROOT/agents/$agent" "$TARGET_DIR/agents/$agent" > /dev/null 2>&1; then
      (( MATCHING++ ))
    else
      (( CUSTOMIZED++ ))
    fi
  done

  while IFS= read -r -d '' f; do
    agent=$(basename "$f")
    found=false
    for a in "${OUR_AGENTS[@]}"; do [[ "$a" == "$agent" ]] && found=true && break; done
    $found || (( EXTRA++ ))
  done < <(find "$TARGET_DIR/agents" -maxdepth 1 -name "*.md" -print0 2>/dev/null)

  [[ $MATCHING -gt 0 ]]   && info "agents/ — $MATCHING agent(s) match our version"
  [[ $CUSTOMIZED -gt 0 ]] && { conflict "agents/ — $CUSTOMIZED agent(s) have custom content"; (( CONFLICTS++ )); }
  [[ $EXTRA -gt 0 ]]      && info "agents/ — $EXTRA custom agent(s) not in our set (will be preserved)"
else
  ok "agents/ — not present, will be created"
fi

# ═════════════════════════════════════════════════════════════════════════════
# 6. SDD SCAFFOLD
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}── SDD Scaffold ─────────────────────────────────────────────────${NC}"

[[ -d "$TARGET_DIR/docs/specs" ]] \
  && info  "docs/specs/ — exists ($(find "$TARGET_DIR/docs/specs" -name "*.md" 2>/dev/null | wc -l | tr -d ' ') spec files)" \
  || ok    "docs/specs/ — not present, will be created (empty)"

[[ -d "$TARGET_DIR/tasks" ]] \
  && info  "tasks/ — exists ($(find "$TARGET_DIR/tasks" -name "*.md" 2>/dev/null | wc -l | tr -d ' ') files)" \
  || ok    "tasks/ — not present, will be created (empty)"

# ═════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}── Summary ──────────────────────────────────────────────────────${NC}"
echo ""

if [[ $CONFLICTS -eq 0 && $WARNINGS -eq 0 ]]; then
  echo -e "  ${GREEN}${BOLD}✓ All clear${NC} — safe to run install.sh"
  echo ""
  echo "  Next step:"
  echo "    bash scripts/install.sh $TARGET_DIR"

elif [[ $CONFLICTS -gt 0 ]]; then
  echo -e "  ${RED}${BOLD}✗ $CONFLICTS conflict(s) found${NC} — review before installing"
  [[ $WARNINGS -gt 0 ]] && echo -e "  ${YELLOW}${BOLD}⚠ $WARNINGS warning(s) found${NC}"
  echo ""
  echo "  Options:"
  echo ""
  echo "  1. BACKUP + FORCE (recommended)"
  echo "     install.sh --backup --force $TARGET_DIR"
  echo "     → Backs up conflicting files to .ai-config-backup/ then overwrites"
  echo "     → You can diff and cherry-pick your customizations afterward"
  echo ""
  echo "  2. MERGE MANUALLY"
  echo "     Review the conflicting files, copy your custom content into"
  echo "     this dotfiles repo, then run install.sh normally"
  echo ""
  echo "  3. SKIP CONFLICTS"
  echo "     install.sh $TARGET_DIR"
  echo "     → Conflicting files are skipped, only missing files are added"

else
  echo -e "  ${YELLOW}${BOLD}⚠ $WARNINGS warning(s)${NC} — review alternates before installing"
  echo ""
  echo "  Warnings are non-blocking. Run install.sh and check afterward"
  echo "  that the right config files are loading in each tool."
  echo ""
  echo "  Next step:"
  echo "    bash scripts/install.sh $TARGET_DIR"
fi

echo ""
