#!/usr/bin/env bash
# Apply this harness to any project, from any AI agent.
#
# Usage (run from your project root):
#   bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/klaach_harness/main/apply.sh)
#
# Non-interactive (for agents):
#   TOOL=claude|codex|all  bash <(curl -fsSL .../apply.sh)
#
# If your tool isn't listed: use TOOL=all, then read HARNESS.md — it maps every
# layer to the mechanism your tool uses, so you can wire it up yourself.

set -euo pipefail

REPO="klaachkinggit/klaach_harness"
RAW="https://raw.githubusercontent.com/${REPO}/main"

echo "=== Dev Harness — Apply ==="
echo "Target: $(pwd)"
echo ""

# ── Tool selection ────────────────────────────────────────────
if [ -z "${TOOL:-}" ]; then
  echo "Which AI coding tool?"
  echo "  1) Claude Code  2) Codex CLI  3) Both"
  read -rp "Choice [1-3]: " CHOICE
  case "$CHOICE" in
    1) TOOL="claude" ;; 2) TOOL="codex" ;; *) TOOL="all" ;;
  esac
fi

fetch() { curl -fsSL "${RAW}/$1"; }
fetch_safe() {  # fetch src → dst, backing up an existing dst first
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then cp "$dst" "${dst}.bak"; echo "  backed up $dst → ${dst}.bak"; fi
  fetch "$src" > "$dst"
}
fetch_hooks() {
  local dir="$1"
  mkdir -p "${dir}/hooks"
  for h in protect-secrets block-dangerous auto-format log-bash pre-pr-gate; do
    fetch "${dir}/hooks/${h}.sh" > "${dir}/hooks/${h}.sh"; chmod +x "${dir}/hooks/${h}.sh"
  done
}

# ── [1/6] Rules ───────────────────────────────────────────────
echo "[1/6] Rules..."
case "$TOOL" in
  claude)  fetch_safe "CLAUDE.md" "CLAUDE.md"; fetch_safe "AGENT.md" "AGENT.md" ;;
  codex)   fetch_safe "AGENTS.md" "AGENTS.md"; fetch_safe "AGENT.md" "AGENT.md" ;;
  all|*)   fetch_safe "CLAUDE.md" "CLAUDE.md"; fetch_safe "AGENTS.md" "AGENTS.md"; fetch_safe "AGENT.md" "AGENT.md" ;;
esac
[ -f ".env.example" ] || fetch ".env.example" > .env.example 2>/dev/null || true

# ── [2/6] Prompts (universal) ─────────────────────────────────
echo "[2/6] Prompts..."
mkdir -p prompts
for p in adopt-harness adr assess-capabilities audit cost-review diagnose grill-me \
         learn memorize preflight risk-review security-scan sparc subagent tdd to-issues zoom-out; do
  fetch "prompts/${p}.md" > "prompts/${p}.md"
done

# ── [3/6] MCP config (per-tool format) ────────────────────────
echo "[3/6] MCP config..."
mkdir -p tools && fetch "tools/gen-mcp.py" > tools/gen-mcp.py
gen_mcp() { python3 tools/gen-mcp.py "$1"; }
case "$TOOL" in
  claude)  gen_mcp claude ;;
  codex)   gen_mcp codex ;;
  all|*)   gen_mcp claude; gen_mcp codex ;;
esac

# ── [4/6] Universal git + CI enforcement (works under ANY tool) ──
echo "[4/6] Git + CI enforcement..."
mkdir -p .githooks
for gh in pre-commit pre-push; do
  fetch ".githooks/${gh}" > ".githooks/${gh}"; chmod +x ".githooks/${gh}"
done
fetch_safe ".github/workflows/ci.yml" ".github/workflows/ci.yml"
if git rev-parse --git-dir >/dev/null 2>&1; then
  EXISTING_HP=$(git config --get core.hooksPath || true)
  if [ -n "$EXISTING_HP" ] && [ "$EXISTING_HP" != ".githooks" ]; then
    echo "  ⚠️  core.hooksPath already set to '$EXISTING_HP' (husky?). NOT overriding."
    echo "     To use these instead: git config core.hooksPath .githooks"
  else
    git config core.hooksPath .githooks
    echo "  activated git hooks (core.hooksPath = .githooks)"
  fi
else
  echo "  not a git repo — run 'git init' then 'git config core.hooksPath .githooks'"
fi

# ── [5/6] Tool-specific runtime (hooks, commands, plugins) ────
echo "[5/6] Runtime extras..."
PLUGIN_FAILED=()

fetch_skills() {
  local dir="$1"
  for skill in find-skills ui-ux-pro-max impeccable awesome-design-md frontend-design web-design-guidelines; do
    mkdir -p "${dir}/skills/${skill}"
    fetch "${dir}/skills/${skill}/SKILL.md" > "${dir}/skills/${skill}/SKILL.md"
  done
}

setup_claude_runtime() {
  mkdir -p .claude/commands
  for c in adopt-harness adr assess-capabilities audit cost-review diagnose grill-me \
           learn memorize preflight risk-review security-scan sparc subagent tdd to-issues zoom-out; do
    fetch ".claude/commands/${c}.md" > ".claude/commands/${c}.md"
  done
  fetch_hooks ".claude"
  fetch_skills ".claude"
  fetch_safe ".claude/settings.json" ".claude/settings.json"
  if command -v claude >/dev/null 2>&1; then
    echo "  installing Claude plugins..."
    # Claude CLI requires a two-step flow: add the marketplace, then install
    # plugin@marketplace. The marketplace name is set inside each repo's
    # .claude-plugin/marketplace.json (not derivable from the GitHub slug),
    # so we hardcode <github-repo>:<marketplace-name>:<plugin-name> tuples.
    for entry in \
      "obra/superpowers:superpowers-dev:superpowers" \
      "anthropics/skills:anthropic-agent-skills:claude-api" \
      "anthropics/skills:anthropic-agent-skills:document-skills"; do
      IFS=':' read -r repo market plugin <<< "$entry"
      claude plugin marketplace add "$repo" >/dev/null 2>&1 || true
      if claude plugin install "${plugin}@${market}" >/dev/null 2>&1; then
        echo "    ✓ ${plugin}@${market}"
      else
        echo "    ✗ ${plugin}@${market}"
        PLUGIN_FAILED+=("${plugin}@${market}")
      fi
    done
    # Trailofbits has ~19 security plugins — add the marketplace so users can
    # pick what they need, rather than installing the whole pack.
    if claude plugin marketplace add trailofbits/skills >/dev/null 2>&1; then
      echo "    ✓ trailofbits marketplace added (install via: claude plugin install <name>@trailofbits)"
    fi
  else
    echo "  claude CLI not found — skipping plugins (rules+prompts+hooks still active)"
  fi
}

setup_codex_runtime() {
  fetch_hooks ".codex"
  fetch_skills ".codex"
  fetch_safe ".codex/hooks.json" ".codex/hooks.json"
  echo "  Codex hooks written to .codex/hooks.json and .codex/hooks/."
  echo "  VERIFY hook stdin field names match your Codex version — see HARNESS.md."
}

case "$TOOL" in
  claude) setup_claude_runtime ;;
  codex)  setup_codex_runtime ;;
  all)    setup_claude_runtime; setup_codex_runtime ;;
esac

# ── [6/6] CodeGraph (code graph + token saver) ───────────────
echo "[6/6] CodeGraph (code graph + token saver)..."
if command -v codegraph >/dev/null 2>&1; then
  codegraph install || true
  codegraph init || true
  echo "  CodeGraph installed and index built (.codegraph/)."
else
  echo "  codegraph not found. Manual setup:"
  echo "    curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh"
  echo "    Then in a new terminal: codegraph install   (auto-wires Claude Code + Codex MCP)"
  echo "    Then: codegraph init                        (builds the local .codegraph/ index)"
  echo "  Optional but recommended: ~-47% tokens / fewer tool calls. 100% local."
fi

# ── Summary + verification ────────────────────────────────────
echo ""
echo "=== Done ==="
echo "Next: copy .env.example → .env (set GITHUB_TOKEN); add project rules at the bottom of your rules file."
echo "Skills: base is lean. Need more (web/docs/etc)? Ask agent to 'find a skill for X' or see PROFILES.md."
echo "Unknown/!listed tool? Read HARNESS.md — it maps every layer to your tool's mechanism."

if [ ${#PLUGIN_FAILED[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  Plugins failed: ${PLUGIN_FAILED[*]} — install manually (check network / claude CLI version)."
fi

echo ""
echo "VERIFY:"
echo "   git config --get core.hooksPath     → should print .githooks"
echo "   ls .claude/hooks/ 2>/dev/null        → 5 scripts if Claude enabled"
echo "   ls .codex/hooks/ 2>/dev/null         → 5 scripts if Codex enabled"
if { [ "$TOOL" = "claude" ] || [ "$TOOL" = "all" ]; } && command -v claude >/dev/null 2>&1; then
  echo "   claude mcp list                      → confirm servers (reads .mcp.json)"
fi
