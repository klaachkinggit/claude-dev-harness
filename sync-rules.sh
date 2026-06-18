#!/usr/bin/env bash
# Regenerates or checks the Codex + Claude rules files from RULES.md (the single source).
# Run this in the HARNESS REPO after editing RULES.md — NOT in target projects.
# In a target project you own the rules files and edit them freely; never run this there.
set -euo pipefail

[ ! -f "RULES.md" ] && echo "Error: run from repo root (RULES.md not found)" && exit 1

CHECK=0
if [ "${1:-}" = "--check" ]; then
  CHECK=1
elif [ "$#" -gt 0 ]; then
  echo "Usage: $0 [--check]" >&2
  exit 2
fi

MARKER=$'\n---\n<!-- Add project-specific rules below this line -->'

render_plain() {
  cat RULES.md
  printf '%s\n' "$MARKER"
}

render_claude() {
  cat RULES.md
  [ -f ".claude-extra.md" ] && cat ".claude-extra.md"
  printf '%s\n' "$MARKER"
}

check_target() {
  local target="$1" renderer="$2" tmp
  tmp=$(mktemp)
  "$renderer" > "$tmp"
  if cmp -s "$tmp" "$target"; then
    echo "  in sync → $target"
    rm -f "$tmp"
    return 0
  fi
  echo "  drift → $target (run ./sync-rules.sh)" >&2
  rm -f "$tmp"
  return 1
}

if [ "$CHECK" -eq 1 ]; then
  failures=0
  check_target "AGENTS.md" render_plain || failures=$((failures + 1))
  check_target "CLAUDE.md" render_claude || failures=$((failures + 1))
  if [ "$failures" -gt 0 ]; then
    echo "Rule sync check failed: $failures file(s) drifted" >&2
    exit 1
  fi
  echo "Rule sync check passed."
  exit 0
fi

# Plain targets: identical copy of RULES.md + project-rules marker.
PLAIN_TARGETS=(
  "AGENTS.md"
)

for target in "${PLAIN_TARGETS[@]}"; do
  mkdir -p "$(dirname "$target")"
  render_plain > "$target"
  echo "  synced → $target"
done

# CLAUDE.md: RULES.md + Claude-specific addendum + marker.
render_claude > "CLAUDE.md"
echo "  synced → CLAUDE.md (+ .claude-extra.md)"

echo ""
echo "Done. All tool rules files regenerated from RULES.md."
