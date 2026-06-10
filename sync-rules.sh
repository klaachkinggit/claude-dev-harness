#!/usr/bin/env bash
# Regenerates every tool-specific rules file from RULES.md (the single source).
# Run this in the HARNESS REPO after editing RULES.md — NOT in target projects.
# In a target project you own the rules files and edit them freely; never run this there.
set -euo pipefail

[ ! -f "RULES.md" ] && echo "Error: run from repo root (RULES.md not found)" && exit 1

MARKER=$'\n---\n<!-- Add project-specific rules below this line -->'

# Plain targets: identical copy of RULES.md + project-rules marker.
PLAIN_TARGETS=(
  "GEMINI.md"
  "AGENTS.md"
  ".cursorrules"
  ".windsurfules"
  ".clinerules"
  ".github/copilot-instructions.md"
)

for target in "${PLAIN_TARGETS[@]}"; do
  mkdir -p "$(dirname "$target")"
  { cat RULES.md; printf '%s\n' "$MARKER"; } > "$target"
  echo "  synced → $target"
done

# CLAUDE.md: RULES.md + Claude-specific addendum + marker.
{ cat RULES.md; [ -f ".claude-extra.md" ] && cat ".claude-extra.md"; printf '%s\n' "$MARKER"; } > "CLAUDE.md"
echo "  synced → CLAUDE.md (+ .claude-extra.md)"

# .cursor/rules/harness.mdc keeps its own frontmatter — regenerate body from RULES.md.
if [ -f ".cursor/rules/harness.mdc" ]; then
  {
    printf -- '---\ndescription: Core dev harness behavioral rules — applies to all files\nalwaysApply: true\n---\n\n'
    # Skip the H1 title line; the frontmatter already frames it.
    tail -n +2 RULES.md
  } > ".cursor/rules/harness.mdc"
  echo "  synced → .cursor/rules/harness.mdc"
fi

echo ""
echo "Done. All tool rules files regenerated from RULES.md."
