#!/usr/bin/env bash
set -euo pipefail

echo "=== Dev Harness Setup ==="
echo ""

# ── Tool selection ────────────────────────────────────────────
echo "Which AI coding tool are you setting up for?"
echo "  1) Claude Code"
echo "  2) Cursor"
echo "  3) Windsurf"
echo "  4) Gemini CLI"
echo "  5) GitHub Copilot"
echo "  6) Other / All (MCP via .mcp.json only)"
echo ""
read -p "Choice [1-6]: " TOOL_CHOICE

# ── MCP Servers ───────────────────────────────────────────────
setup_mcp_claude() {
  echo ""
  echo "[MCP] Adding servers (project scope)..."

  claude mcp add --scope project github -- \
    npx -y @modelcontextprotocol/server-github

  claude mcp add --scope project --transport stdio filesystem -- \
    npx -y @modelcontextprotocol/server-filesystem .

  claude mcp add --scope project --transport stdio git -- \
    npx -y @modelcontextprotocol/server-git .

  claude mcp add --scope project --transport stdio playwright -- \
    npx -y @playwright/mcp

  if [ -n "${DATABASE_URL:-}" ]; then
    echo "  Adding PostgreSQL MCP..."
    claude mcp add --scope project --transport stdio db -- \
      npx -y @bytebase/dbhub --dsn "$DATABASE_URL"
  else
    echo "  Skipping DB MCP — set DATABASE_URL to enable"
  fi
}

setup_mcp_json() {
  echo ""
  echo "[MCP] .mcp.json already present — edit to add DATABASE_URL if needed."
  if [ -n "${DATABASE_URL:-}" ]; then
    # Inject db server into .mcp.json using node
    node -e "
const fs = require('fs');
const cfg = JSON.parse(fs.readFileSync('.mcp.json', 'utf8'));
cfg.mcpServers.db = {
  command: 'npx',
  args: ['-y', '@bytebase/dbhub', '--dsn', process.env.DATABASE_URL]
};
fs.writeFileSync('.mcp.json', JSON.stringify(cfg, null, 2));
console.log('  Added db server to .mcp.json');
" 2>/dev/null || echo "  Could not auto-inject DB — add manually to .mcp.json"
  fi
}

# ── Plugins (Claude Code only) ────────────────────────────────
setup_plugins_claude() {
  echo ""
  echo "[Plugins] Installing..."

  claude plugin install obra/superpowers      # 7-phase prod methodology
  claude plugin install mattpocock/skills     # /grill-me, /tdd, /diagnose, /zoom-out
  claude plugin install vercel-labs/agent-skills  # 100+ UI/a11y/perf rules
  claude plugin install anthropics/skills     # frontend design + doc generation
  claude plugin install trailofbits/skills    # CodeQL + Semgrep security
  claude plugin install JuliusBrussee/caveman # 65-75% token reduction
}

# ── Rules file setup ──────────────────────────────────────────
setup_rules_gemini() {
  echo "[Rules] GEMINI.md ready."
}

setup_rules_cursor() {
  echo "[Rules] .cursorrules + .cursor/rules/harness.mdc ready."
}

setup_rules_windsurf() {
  echo "[Rules] .windsurfules ready."
}

setup_rules_copilot() {
  echo "[Rules] .github/copilot-instructions.md ready."
}

# ── Run setup ─────────────────────────────────────────────────
case $TOOL_CHOICE in
  1)
    echo ""
    echo "Setting up for Claude Code..."
    setup_mcp_claude
    setup_plugins_claude
    echo ""
    echo "Done. Verify: claude mcp list"
    echo "Activate: /caveman ultra"
    ;;
  2)
    echo ""
    echo "Setting up for Cursor..."
    setup_mcp_json
    setup_rules_cursor
    echo ""
    echo "Done. Open project in Cursor — .cursorrules and .cursor/rules/ are auto-loaded."
    echo "MCP servers: configure via Cursor Settings → MCP (reads .mcp.json)."
    ;;
  3)
    echo ""
    echo "Setting up for Windsurf..."
    setup_mcp_json
    setup_rules_windsurf
    echo ""
    echo "Done. .windsurfules is auto-loaded by Windsurf."
    echo "MCP servers: configure via Windsurf Settings → MCP."
    ;;
  4)
    echo ""
    echo "Setting up for Gemini CLI..."
    setup_mcp_json
    setup_rules_gemini
    echo ""
    echo "Done. GEMINI.md is auto-loaded by Gemini CLI."
    echo "MCP servers: configure via ~/.gemini/settings.json (copy from .mcp.json)."
    ;;
  5)
    echo ""
    echo "Setting up for GitHub Copilot..."
    setup_rules_copilot
    echo ""
    echo "Done. .github/copilot-instructions.md is auto-loaded by Copilot."
    echo "MCP servers: configure via VS Code MCP extension settings."
    ;;
  6|*)
    echo ""
    echo "Setting up generic (MCP via .mcp.json)..."
    setup_mcp_json
    echo ""
    echo "Done. Load the rules file for your tool:"
    echo "  Claude Code  →  CLAUDE.md (auto)"
    echo "  Cursor       →  .cursorrules / .cursor/rules/ (auto)"
    echo "  Windsurf     →  .windsurfules (auto)"
    echo "  Gemini CLI   →  GEMINI.md (auto)"
    echo "  Copilot      →  .github/copilot-instructions.md (auto)"
    echo "  Cline        →  .clinerules (auto)"
    echo "  Other        →  copy RULES.md content into your system prompt"
    ;;
esac

echo ""
echo "Prompts (paste into any tool): prompts/"
