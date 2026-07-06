#!/usr/bin/env bash
set -euo pipefail

REPO="klaachkinggit/klaach_harness"
RAW="${HARNESS_RAW_BASE:-https://raw.githubusercontent.com/${REPO}/main}"
RAW="${RAW%/}"

echo "=== Codex Harness - Apply ==="
echo "Target: $(pwd)"
echo ""

fetch() { curl -fsSL "${RAW}/$1"; }

fetch_safe() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then
    cp "$dst" "${dst}.bak"
    echo "  backed up $dst -> ${dst}.bak"
  fi
  fetch "$src" > "$dst"
}

fetch_rules() {
  local src="$1" dst="$2" tmp marker tail
  tmp="$(mktemp)"
  marker="<!-- Add project-specific rules below this line -->"
  fetch "$src" > "$tmp"
  if [ -f "$dst" ]; then
    cp "$dst" "${dst}.bak"
    echo "  backed up $dst -> ${dst}.bak"
  fi
  python3 - "$tmp" "$dst" "$marker" <<'PY'
from pathlib import Path
import sys

template = Path(sys.argv[1]).read_text()
target = Path(sys.argv[2])
marker = sys.argv[3]
existing = target.read_text() if target.exists() else ""
tail = ""
if existing and marker in existing:
    tail = existing.split(marker, 1)[1].strip()
elif existing and existing != template:
    tail = existing.strip()
if tail and tail not in template:
    target.write_text(template.rstrip() + "\n\n" + tail.rstrip() + "\n")
else:
    target.write_text(template)
PY
  rm -f "$tmp"
  echo "  wrote $dst"
}

merge_json_config() {
  local src="$1" dst="$2" tmp
  tmp="$(mktemp)"
  fetch "$src" > "$tmp"
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then
    cp "$dst" "${dst}.bak"
    echo "  backed up $dst -> ${dst}.bak"
  fi
  python3 - "$tmp" "$dst" <<'PY'
import json
import sys
from pathlib import Path

template_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])
template = json.loads(template_path.read_text())
existing = {}
if target_path.exists() and target_path.read_text().strip():
    existing = json.loads(target_path.read_text())

merged = dict(existing)
hooks = dict(existing.get("hooks", {}))
for event, blocks in template.get("hooks", {}).items():
    hooks[event] = blocks
merged["hooks"] = hooks
target_path.write_text(json.dumps(merged, indent=2) + "\n")
PY
  rm -f "$tmp"
  echo "  wrote $dst"
}

echo "[1/5] Rules and docs..."
rm -rf .claude prompts .mcp.json CLAUDE.md RULES.md sync-rules.sh .claude-extra.md
rm -rf \
  .codex/hooks/auto-format.sh \
  .codex/hooks/block-dangerous.sh \
  .codex/hooks/log-bash.sh \
  .codex/hooks/pre-pr-gate.sh \
  .codex/hooks/project-scope.sh \
  .codex/hooks/protect-secrets.sh \
  .codex/skills/awesome-design-md \
  .codex/skills/frontend-design \
  .codex/skills/impeccable \
  .codex/skills/ui-ux-pro-max \
  .codex/skills/web-design-guidelines \
  .codex/skills/matt-pocock-diagnose \
  .codex/skills/matt-pocock-grill-me \
  .codex/skills/matt-pocock-tdd \
  .codex/skills/matt-pocock-to-issues \
  .codex/skills/matt-pocock-zoom-out
fetch_rules "AGENTS.md" "AGENTS.md"
[ -f ".env.example" ] || fetch ".env.example" > .env.example 2>/dev/null || true
for file in APPLY.md HARNESS.md PROFILES.md README.md docs/agent-work-environment.md; do
  fetch_safe "$file" "$file"
done
[ -f "MEMORY.md" ] || fetch "MEMORY.md" > MEMORY.md 2>/dev/null || true
[ -f "LESSONS.md" ] || fetch "LESSONS.md" > LESSONS.md 2>/dev/null || true
mkdir -p docs/adr
[ -f "docs/adr/0000-template.md" ] || fetch "docs/adr/0000-template.md" > docs/adr/0000-template.md 2>/dev/null || true

echo "[2/5] MCP config..."
mkdir -p tools
for file in gen-mcp.py profile.py; do
  fetch "tools/${file}" > "tools/${file}"
done
chmod +x tools/profile.py
for tool in audit-capabilities apply-profile remove-profile check-agent-context check-profile preflight-harness finish-harness update-harness; do
  fetch "tools/${tool}.sh" > "tools/${tool}.sh"
  chmod +x "tools/${tool}.sh"
done
python3 tools/gen-mcp.py codex
if ! command -v uvx >/dev/null 2>&1; then
  echo "  warning: uvx not found - git MCP will not start until uv is installed."
fi

echo "[3/5] Git + CI enforcement..."
mkdir -p .githooks
for hook in pre-commit pre-push; do
  fetch ".githooks/${hook}" > ".githooks/${hook}"
  chmod +x ".githooks/${hook}"
done
fetch_safe ".github/workflows/ci.yml" ".github/workflows/ci.yml"
if git rev-parse --git-dir >/dev/null 2>&1; then
  existing_hooks_path="$(git config --get core.hooksPath || true)"
  if [ -n "$existing_hooks_path" ] && [ "$existing_hooks_path" != ".githooks" ]; then
    echo "  warning: core.hooksPath already set to '$existing_hooks_path'; not overriding."
  else
    git config core.hooksPath .githooks
    echo "  activated git hooks (core.hooksPath = .githooks)"
  fi
fi

echo "[4/5] Codex runtime..."
mkdir -p .codex/hooks .codex/skills
fetch ".codex/hooks/protect-env.sh" > ".codex/hooks/protect-env.sh"
chmod +x ".codex/hooks/protect-env.sh"
merge_json_config ".codex/hooks.json" ".codex/hooks.json"
for skill in find-skills superpowers grill-me tdd diagnosing-bugs to-issues codebase-design improve-codebase-architecture ponytail; do
  mkdir -p ".codex/skills/${skill}"
  fetch ".codex/skills/${skill}/SKILL.md" > ".codex/skills/${skill}/SKILL.md"
done

echo "[5/5] CodeGraph..."
if [ "${SKIP_CODEGRAPH:-0}" = "1" ]; then
  echo "  skipped CodeGraph (SKIP_CODEGRAPH=1)."
elif command -v codegraph >/dev/null 2>&1; then
  [ "${INSTALL_CODEGRAPH_MCP:-0}" = "1" ] && codegraph install || true
  codegraph init || true
else
  echo "  codegraph not found; skipping optional local index."
fi

echo ""
echo "=== Done ==="
echo "Next:"
echo "  git config --get core.hooksPath"
echo "  tools/check-agent-context.sh"
echo "  tools/check-profile.sh"
echo "  tools/preflight-harness.sh"
echo "  tools/finish-harness.sh"
