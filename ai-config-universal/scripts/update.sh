#!/usr/bin/env bash
# =============================================================================
# ai-config-universal — dotfiles updater
#
# Reads ~/.ai-config-projects (written by install.sh) and pushes the latest
# config changes to every registered project.
#
# Usage:
#   ./scripts/update.sh                  # update all registered projects
#   ./scripts/update.sh --list           # list registered projects, no changes
#   ./scripts/update.sh --dry-run        # preview what would change
#   ./scripts/update.sh --remove <path>  # unregister a project
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="${CONFIG_ROOT:-$(dirname "$SCRIPT_DIR")}"
REGISTRY="${HOME}/.ai-config-projects"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
ok()     { echo -e "${GREEN}  ✓${NC} $1"; }
info()   { echo -e "${BLUE}  →${NC} $1"; }
warn()   { echo -e "${YELLOW}  ⚠${NC} $1"; }
err()    { echo -e "${RED}  ✗${NC} $1"; exit 1; }
header() { echo -e "\n${BOLD}$1${NC}"; }

# ── Parse arguments ───────────────────────────────────────────────────────────
LIST_ONLY=false
DRY_RUN=false
REMOVE_PATH=""

for arg in "$@"; do
  case "$arg" in
    --list)       LIST_ONLY=true ;;
    --dry-run)    DRY_RUN=true ;;
    --remove)     ;;   # handled below with next arg
    --help|-h)
      cat <<EOF

Usage: update.sh [options]

Options:
  --list          Show all registered projects without updating
  --dry-run       Preview what would be updated without making changes
  --remove <path> Unregister a project (stops future updates to it)
  --help          Show this help

How it works:
  1. install.sh records every project path to ~/.ai-config-projects
  2. update.sh reads that file and runs install.sh --force on each project
  3. Only the AI config files are overwritten — your project code is untouched

Typical workflow:
  cd ~/dotfiles && git pull          # get latest config changes
  bash ai-config-universal/scripts/update.sh  # push to all projects

EOF
      exit 0
      ;;
    *) REMOVE_PATH="$arg" ;;  # path after --remove
  esac
done

# Handle --remove
if [[ "${1:-}" == "--remove" ]]; then
  [[ -n "$REMOVE_PATH" ]] || err "Usage: update.sh --remove <project-path>"
  ABS_REMOVE="$(cd "$REMOVE_PATH" 2>/dev/null && pwd)" || err "Path not found: $REMOVE_PATH"
  if grep -qF "$ABS_REMOVE" "$REGISTRY" 2>/dev/null; then
    grep -vF "$ABS_REMOVE" "$REGISTRY" > "$REGISTRY.tmp" && mv "$REGISTRY.tmp" "$REGISTRY"
    ok "Unregistered: $ABS_REMOVE"
  else
    warn "Not in registry: $ABS_REMOVE"
  fi
  exit 0
fi

# ── Validate ──────────────────────────────────────────────────────────────────
[[ -f "$REGISTRY" ]] || err "No projects registered yet. Run install.sh <path> first.\nRegistry: $REGISTRY"
[[ -f "$INSTALL_SCRIPT" ]] || err "install.sh not found at: $INSTALL_SCRIPT"

# Read registry — filter out blank lines and comments
mapfile -t PROJECTS < <(grep -v '^\s*$' "$REGISTRY" | grep -v '^\s*#' || true)
[[ ${#PROJECTS[@]} -gt 0 ]] || err "Registry is empty. Run install.sh <path> to register projects."

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       ai-config-universal  ·  updater            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo "  Config source : $CONFIG_ROOT"
echo "  Registry      : $REGISTRY"
echo "  Projects found: ${#PROJECTS[@]}"
$DRY_RUN && echo "  Dry run       : YES — no files will be changed"
echo ""

# ── List mode ─────────────────────────────────────────────────────────────────
if $LIST_ONLY; then
  echo "  Registered projects:"
  echo ""
  idx=1
  for project in "${PROJECTS[@]}"; do
    if [[ -d "$project" ]]; then
      echo -e "  ${GREEN}[$idx]${NC} $project"
    else
      echo -e "  ${RED}[$idx] MISSING${NC} $project"
    fi
    (( idx++ ))
  done
  echo ""
  echo "  To update all:   bash scripts/update.sh"
  echo "  To remove one:   bash scripts/update.sh --remove <path>"
  echo ""
  exit 0
fi

# ── Update each project ───────────────────────────────────────────────────────
UPDATED=0
SKIPPED=0
MISSING=0
FAILED=0

for project in "${PROJECTS[@]}"; do
  echo "─────────────────────────────────────────────────────────────────"
  echo -e "  ${BOLD}Project:${NC} $project"

  # Check if directory still exists
  if [[ ! -d "$project" ]]; then
    warn "Directory not found — skipping (remove with: update.sh --remove $project)"
    (( MISSING++ ))
    echo ""
    continue
  fi

  # Run install --force to overwrite config files
  if $DRY_RUN; then
    bash "$INSTALL_SCRIPT" --dry-run --force "$project" 2>&1 | grep -E '^\s+(\[dry\]|✓|⚠|✗)' || true
    (( UPDATED++ ))
  else
    if bash "$INSTALL_SCRIPT" --force "$project" 2>&1 | grep -E '^\s+(✓|⚠|✗)' ; then
      (( UPDATED++ ))
    else
      warn "Update may have had issues — check output above"
      (( FAILED++ ))
    fi
  fi
  echo ""
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo "═════════════════════════════════════════════════════════════════"
echo ""
if $DRY_RUN; then
  echo -e "  ${BOLD}Dry run complete${NC} — no files were changed"
else
  echo -e "  ${BOLD}Update complete${NC}"
fi
echo ""
echo "  Projects updated : $UPDATED"
[[ $MISSING -gt 0 ]] && echo -e "  ${YELLOW}Directories missing: $MISSING (paths no longer exist)${NC}"
[[ $FAILED  -gt 0 ]] && echo -e "  ${RED}Failed: $FAILED${NC}"
echo ""
[[ $MISSING -gt 0 ]] && echo "  Clean up missing paths:"
[[ $MISSING -gt 0 ]] && echo "    bash scripts/update.sh --list   # see which ones"
[[ $MISSING -gt 0 ]] && echo "    bash scripts/update.sh --remove <path>"
echo ""
