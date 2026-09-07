#!/usr/bin/env bash
# =============================================================================
# Automated Test Suite for ai-config-universal distribution & conflict scenarios
#
# Usage:
#   bash scripts/test-scenarios.sh
#
# Environment Variables (Optional overrides):
#   CONFIG_ROOT  Path to ai-config-universal directory (default: auto-detected)
#   TEST_BASE    Path to temporary test sandbox directory (default: ../../test-sandbox-suite)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="${CONFIG_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
TEST_BASE="${TEST_BASE:-$SCRIPT_DIR/../../test-sandbox-suite}"

GREEN='\033[0;32m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
pass() { echo -e "${GREEN}  ✓ PASS:${NC} $1"; }
fail() { echo -e "${RED}  ✗ FAIL:${NC} $1"; exit 1; }
info() { echo -e "\n${BLUE}▶ SCENARIO:${NC} $1"; }

cleanup() {
  rm -rf "$TEST_BASE"
}
trap cleanup EXIT

cleanup
mkdir -p "$TEST_BASE"

# -----------------------------------------------------------------------------
info "1. Clean Project Install (Fresh Repo)"
# -----------------------------------------------------------------------------
REPO_1="$TEST_BASE/repo-fresh"
mkdir -p "$REPO_1"

# Scan should detect all clean
SCAN_OUT=$(bash "$CONFIG_ROOT/scripts/scan.sh" "$REPO_1")
if echo "$SCAN_OUT" | grep -q "All clear"; then
  pass "scan.sh reports All Clear on fresh repo"
else
  fail "scan.sh did not report clean state on fresh repo"
fi

# Run install.sh
bash "$CONFIG_ROOT/scripts/install.sh" "$REPO_1" > /dev/null

# Assert files created
[[ -f "$REPO_1/CLAUDE.md" ]] || fail "CLAUDE.md not created"
[[ -f "$REPO_1/AGENT.md" ]] || fail "AGENT.md not created"
[[ -d "$REPO_1/output-styles" ]] || fail "output-styles/ not created"
[[ -f "$REPO_1/.github/copilot-instructions.md" ]] || fail "copilot-instructions.md not created"
[[ -f "$REPO_1/.agents/rules/engineering-principles.md" ]] || fail "AGY rules not created"
[[ -f "$REPO_1/.agents/README.md" ]] || fail ".agents/README.md not created"
[[ -f "$REPO_1/.editorconfig" ]] || fail ".editorconfig not created"
[[ -f "$REPO_1/.gitignore" ]] || fail ".gitignore not created"
[[ -d "$REPO_1/skills/spec-driven-development" ]] || fail "SDD skill not copied"
[[ -d "$REPO_1/agents" ]] || fail "agents/ not copied"
[[ -d "$REPO_1/docs/specs" ]] || fail "docs/specs/ scaffold not created"
[[ -d "$REPO_1/tasks" ]] || fail "tasks/ scaffold not created"
pass "All core files and directories installed successfully"

# -----------------------------------------------------------------------------
info "2. Same Name, Same Location with Custom Content (Conflict & Backup)"
# -----------------------------------------------------------------------------
REPO_2="$TEST_BASE/repo-custom-claude"
mkdir -p "$REPO_2"
echo "# Custom Project Instructions" > "$REPO_2/CLAUDE.md"

# Scan should detect conflict
SCAN_OUT_2=$(bash "$CONFIG_ROOT/scripts/scan.sh" "$REPO_2")
if echo "$SCAN_OUT_2" | grep -q "1 conflict"; then
  pass "scan.sh detected conflict on custom CLAUDE.md"
else
  fail "scan.sh failed to detect conflict on custom CLAUDE.md"
fi

# Default install should skip without overwriting
bash "$CONFIG_ROOT/scripts/install.sh" "$REPO_2" > /dev/null
grep -q "Custom Project Instructions" "$REPO_2/CLAUDE.md" || fail "Default install overwrote custom file without --force"
pass "Default install skipped existing customized file"

# Install with --backup --force
bash "$CONFIG_ROOT/scripts/install.sh" --backup --force "$REPO_2" > /dev/null

# Assert backup created
BACKUP_FILE=$(find "$REPO_2/.ai-config-backup" -name "CLAUDE.md" 2>/dev/null | head -n 1)
[[ -n "$BACKUP_FILE" && -f "$BACKUP_FILE" ]] || fail "Backup of original CLAUDE.md was not created"
grep -q "Custom Project Instructions" "$BACKUP_FILE" || fail "Backup does not contain original content"
pass "Backup accurately captured previous custom content"

# Assert target now has universal version
grep -q "AI-Enabled Software Engineer" "$REPO_2/CLAUDE.md" || fail "CLAUDE.md was not updated with universal version"
pass "Universal version successfully installed after backup"

# -----------------------------------------------------------------------------
info "3. Same Name in Different Locations / Alternate Names"
# -----------------------------------------------------------------------------
REPO_3="$TEST_BASE/repo-alternates"
mkdir -p "$REPO_3/.agent" "$REPO_3/.github"
touch "$REPO_3/AGENT.md"
touch "$REPO_3/.github/copilot.md"

SCAN_OUT_3=$(bash "$CONFIG_ROOT/scripts/scan.sh" "$REPO_3")
if echo "$SCAN_OUT_3" | grep -q "Alternate Claude config found: AGENT.md" && \
   echo "$SCAN_OUT_3" | grep -q "Alternate Copilot config found: .github/copilot.md" && \
   echo "$SCAN_OUT_3" | grep -q "Alternate AGY folder found: .agent/"; then
  pass "scan.sh identified all 3 alternate names/locations"
else
  fail "scan.sh missed one or more alternate naming patterns"
fi

# -----------------------------------------------------------------------------
info "4. Partial Install with Extra Custom Skills & Agents"
# -----------------------------------------------------------------------------
REPO_4="$TEST_BASE/repo-custom-skills"
mkdir -p "$REPO_4/skills/my-internal-proprietary-skill"
echo "custom agent" > "$REPO_4/skills/my-internal-proprietary-skill/SKILL.md"

mkdir -p "$REPO_4/agents"
echo "custom agent role" > "$REPO_4/agents/custom-domain-expert.md"

# Install into partial repo
bash "$CONFIG_ROOT/scripts/install.sh" "$REPO_4" > /dev/null

# Assert standard skills and agents were added
[[ -d "$REPO_4/skills/spec-driven-development" ]] || fail "Standard SDD skill missing"
[[ -f "$REPO_4/agents/code-reviewer.md" ]] || fail "Standard code-reviewer agent missing"

# Assert existing custom skill and agent were preserved
[[ -f "$REPO_4/skills/my-internal-proprietary-skill/SKILL.md" ]] || fail "Custom skill was deleted!"
[[ -f "$REPO_4/agents/custom-domain-expert.md" ]] || fail "Custom agent was deleted!"
pass "Standard skills/agents added while preserving custom/extra skills & agents"

# -----------------------------------------------------------------------------
info "5. Dry-Run Integrity Check"
# -----------------------------------------------------------------------------
REPO_5="$TEST_BASE/repo-dry-run"
mkdir -p "$REPO_5"

DRY_OUT=$(bash "$CONFIG_ROOT/scripts/install.sh" --dry-run "$REPO_5")
if echo "$DRY_OUT" | grep -F "copy →" | grep -q "CLAUDE.md"; then
  pass "Dry run emitted preview actions"
else
  fail "Dry run output format unexpected: $DRY_OUT"
fi

# Verify directory is still empty
FILE_COUNT=$(find "$REPO_5" -type f | wc -l | tr -d ' ')
[[ "$FILE_COUNT" -eq 0 ]] || fail "Dry-run wrote $FILE_COUNT files to disk!"
pass "Dry run wrote zero files to disk"

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN}  ALL 5 SCENARIO TEST CASES PASSED SUCCESSFULLY!${NC}"
echo -e "${GREEN}======================================================\n"
