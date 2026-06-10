#!/usr/bin/env bash
# Apply this harness to any project from any AI agent.
#
# Usage (run from your project root):
#   bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/claude-dev-harness/main/apply.sh)
#
# Non-interactive (for agents):
#   TOOL=claude  bash <(curl -fsSL ...)
#   TOOL=cursor  bash <(curl -fsSL ...)
#   TOOL=windsurf bash <(curl -fsSL ...)
#   TOOL=gemini  bash <(curl -fsSL ...)
#   TOOL=copilot bash <(curl -fsSL ...)
#   TOOL=cline   bash <(curl -fsSL ...)
#   TOOL=all     bash <(curl -fsSL ...)   ← drops all files for all tools

set -euo pipefail

REPO="klaachkinggit/claude-dev-harness"
RAW="https://raw.githubusercontent.com/${REPO}/main"

echo "=== Dev Harness — Apply ==="
echo "Target: $(pwd)"
echo ""

# ── Tool selection ────────────────────────────────────────────
if [ -z "${TOOL:-}" ]; then
  echo "Which AI coding tool?"
  echo "  1) Claude Code"
  echo "  2) Cursor"
  echo "  3) Windsurf"
  echo "  4) Gemini CLI"
  echo "  5) GitHub Copilot"
  echo "  6) Cline"
  echo "  7) All / Other"
  read -rp "Choice [1-7]: " CHOICE
  case "$CHOICE" in
    1) TOOL="claude" ;;
    2) TOOL="cursor" ;;
    3) TOOL="windsurf" ;;
    4) TOOL="gemini" ;;
    5) TOOL="copilot" ;;
    6) TOOL="cline" ;;
    *) TOOL="all" ;;
  esac
fi

fetch() { curl -fsSL "${RAW}/$1"; }

# Fetch into a destination, backing up any existing file first.
fetch_safe() {
  local src="$1" dst="$2"
  if [ -f "$dst" ]; then
    cp "$dst" "${dst}.bak"
    echo "  backed up existing $dst → ${dst}.bak"
  fi
  fetch "$src" > "$dst"
}

# ── Rules file ────────────────────────────────────────────────
echo "[1/3] Rules..."
case "$TOOL" in
  claude)
    fetch_safe "CLAUDE.md" "CLAUDE.md" ;;
  cursor)
    fetch_safe "RULES.md" ".cursorrules"
    mkdir -p .cursor/rules
    fetch_safe ".cursor/rules/harness.mdc" ".cursor/rules/harness.mdc" ;;
  windsurf)
    fetch_safe "RULES.md" ".windsurfules" ;;
  gemini)
    fetch_safe "RULES.md" "GEMINI.md" ;;
  copilot)
    mkdir -p .github
    fetch_safe "RULES.md" ".github/copilot-instructions.md" ;;
  cline)
    fetch_safe "RULES.md" ".clinerules" ;;
  all|*)
    fetch_safe "CLAUDE.md" "CLAUDE.md"
    fetch_safe "RULES.md" "GEMINI.md"
    fetch_safe "RULES.md" "AGENTS.md"
    fetch_safe "RULES.md" ".cursorrules"
    fetch_safe "RULES.md" ".windsurfules"
    fetch_safe "RULES.md" ".clinerules"
    mkdir -p .github .cursor/rules
    fetch_safe "RULES.md" ".github/copilot-instructions.md"
    fetch_safe ".cursor/rules/harness.mdc" ".cursor/rules/harness.mdc" ;;
esac
fetch_safe ".mcp.json" ".mcp.json"
[ -f ".env.example" ] || fetch ".env.example" > .env.example 2>/dev/null || true

# ── Universal prompts ─────────────────────────────────────────
echo "[2/3] Prompts..."
mkdir -p prompts
for p in grill-me tdd diagnose to-issues zoom-out handoff security-scan preflight; do
  fetch "prompts/${p}.md" > "prompts/${p}.md"
done

# ── Claude Code extras ────────────────────────────────────────
MCP_FAILED=()
PLUGIN_FAILED=()

if [ "$TOOL" = "claude" ] || [ "$TOOL" = "all" ]; then
  echo "[3/3] Claude Code files (commands, hooks, settings)..."
  mkdir -p .claude/commands .claude/hooks .claude/skills/caveman

  for cmd in grill-me tdd diagnose to-issues zoom-out handoff security-scan preflight; do
    fetch ".claude/commands/${cmd}.md" > ".claude/commands/${cmd}.md"
  done

  for hook in protect-secrets block-dangerous auto-format log-bash pre-pr-gate; do
    fetch ".claude/hooks/${hook}.sh" > ".claude/hooks/${hook}.sh"
    chmod +x ".claude/hooks/${hook}.sh"
  done

  fetch_safe ".claude/settings.json" ".claude/settings.json"
  fetch ".claude/skills/caveman/SKILL.md" > .claude/skills/caveman/SKILL.md

  # MCP servers — surface failures instead of swallowing them.
  if command -v claude >/dev/null 2>&1; then
    echo ""
    echo "Setting up MCP servers..."
    add_mcp() {
      local name="$1"; shift
      if claude mcp add "$@"; then
        echo "  ✓ $name"
      else
        echo "  ✗ $name (see error above)"
        MCP_FAILED+=("$name")
      fi
    }
    add_mcp github --scope project github -- npx -y @modelcontextprotocol/server-github
    add_mcp filesystem --scope project --transport stdio filesystem -- npx -y @modelcontextprotocol/server-filesystem .
    add_mcp git --scope project --transport stdio git -- npx -y @modelcontextprotocol/server-git .
    add_mcp playwright --scope project --transport stdio playwright -- npx -y @playwright/mcp
    if [ -n "${DATABASE_URL:-}" ]; then
      add_mcp db --scope project --transport stdio db -- npx -y @bytebase/dbhub --dsn "$DATABASE_URL"
    fi

    # Plugins — track failures, report at end.
    echo ""
    echo "Installing plugins..."
    for plugin in obra/superpowers mattpocock/skills vercel-labs/agent-skills anthropics/skills trailofbits/skills JuliusBrussee/caveman; do
      if claude plugin install "$plugin" >/dev/null 2>&1; then
        echo "  ✓ $plugin"
      else
        echo "  ✗ $plugin"
        PLUGIN_FAILED+=("$plugin")
      fi
    done
  else
    echo "  claude CLI not found — MCP and plugin setup skipped"
    MCP_FAILED+=("ALL (claude CLI missing)")
  fi
else
  echo "[3/3] Skipped (non-Claude tool — use .mcp.json for MCP server config)"
fi

# ── Summary + verification ────────────────────────────────────
echo ""
echo "=== Done ==="
echo ""
echo "Next: add project-specific rules at the bottom of your rules file."
echo "Prompts: see prompts/ for workflow templates (paste into any tool)."
echo "Env vars: copy .env.example → .env and fill in GITHUB_TOKEN."

if [ ${#MCP_FAILED[@]} -gt 0 ] || [ ${#PLUGIN_FAILED[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  Some setup steps FAILED — harness is only partially installed:"
  [ ${#MCP_FAILED[@]} -gt 0 ] && echo "   MCP servers: ${MCP_FAILED[*]}"
  [ ${#PLUGIN_FAILED[@]} -gt 0 ] && echo "   Plugins: ${PLUGIN_FAILED[*]}"
  echo "   Re-run after fixing (e.g. set GITHUB_TOKEN, check network), or install manually."
fi

if { [ "$TOOL" = "claude" ] || [ "$TOOL" = "all" ]; } && command -v claude >/dev/null 2>&1; then
  echo ""
  echo "VERIFY setup:"
  echo "   claude mcp list      ← confirm servers are registered"
  echo "   ls .claude/hooks/    ← confirm 5 hook scripts present"
fi
