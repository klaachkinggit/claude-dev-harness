#!/usr/bin/env bash
# Syncs RULES.md to all tool-specific rules files.
# CLAUDE.md is NOT synced — it has extra Claude-specific content, update manually.
set -euo pipefail

[ ! -f "RULES.md" ] && echo "Error: run from repo root (RULES.md not found)" && exit 1

TARGETS=(
  "GEMINI.md"
  "AGENTS.md"
  ".cursorrules"
  ".windsurfules"
  ".clinerules"
  ".github/copilot-instructions.md"
)

for target in "${TARGETS[@]}"; do
  mkdir -p "$(dirname "$target")"
  cp RULES.md "$target"
  echo "  synced → $target"
done

echo ""
echo "Done. CLAUDE.md not synced — update manually if base rules changed."
