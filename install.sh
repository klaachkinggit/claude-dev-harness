#!/usr/bin/env bash
set -euo pipefail

echo "=== Claude Dev Harness — Setup ==="
echo ""

# ── MCP Servers (project scope) ──────────────────────────────
echo "[1/2] Adding MCP servers..."

# GitHub — repo, PR, issue management
claude mcp add --scope project github -- \
  npx -y @modelcontextprotocol/server-github

# Filesystem — project file access
claude mcp add --scope project --transport stdio filesystem -- \
  npx -y @modelcontextprotocol/server-filesystem .

# Git — history, diff, blame, commit ops
claude mcp add --scope project --transport stdio git -- \
  npx -y @modelcontextprotocol/server-git .

# Playwright — browser automation + E2E (Microsoft official)
claude mcp add --scope project --transport stdio playwright -- \
  npx -y @playwright/mcp

# PostgreSQL — optional, reads DATABASE_URL from env
if [ -n "${DATABASE_URL:-}" ]; then
  echo "  Adding PostgreSQL MCP..."
  claude mcp add --scope project --transport stdio db -- \
    npx -y @bytebase/dbhub --dsn "$DATABASE_URL"
else
  echo "  Skipping DB MCP — set DATABASE_URL env var to enable"
fi

echo ""

# ── Plugins ───────────────────────────────────────────────────
echo "[2/2] Installing plugins..."

# Production dev methodology: 7-phase, TDD-enforced, subagent isolation
claude plugin install obra/superpowers

# Engineering discipline: /grill-me, /tdd, /diagnose, /to-issues, /zoom-out
claude plugin install mattpocock/skills

# UI/frontend quality: 100+ a11y/perf/UX rules, react best practices
claude plugin install vercel-labs/agent-skills

# Frontend design direction + document generation (Word/PDF/Excel/PPTX)
claude plugin install anthropics/skills

# Security: CodeQL + Semgrep + variant analysis (Trail of Bits)
claude plugin install trailofbits/skills

# Token optimization: 65-75% reduction in output tokens
claude plugin install JuliusBrussee/caveman

echo ""
echo "=== Done ==="
echo ""
echo "Next steps:"
echo "  claude mcp list          — verify MCP servers"
echo "  /caveman ultra           — activate token optimization"
echo "  /grill-me <feature>      — start your first task"
