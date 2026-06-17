#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"

cleanup() {
  local status=$?
  if [ "$status" -eq 0 ]; then
    rm -rf "$TMP"
  else
    echo "Temp project kept for inspection: $TMP" >&2
  fi
}
trap cleanup EXIT

RAW_BASE="$(python3 - "$ROOT" <<'PY'
from pathlib import Path
import sys

print(Path(sys.argv[1]).resolve().as_uri())
PY
)"

mkdir -p "$TMP/home" "$TMP/project"
cd "$TMP/project"
git init -q

HOME="$TMP/home" TOOL=all HARNESS_RAW_BASE="$RAW_BASE" SKIP_CODEGRAPH=1 bash "$ROOT/apply.sh" >/dev/null

test "$(git config --get core.hooksPath)" = ".githooks"
test -f AGENTS.md
test -f CLAUDE.md
test -f .mcp.json
test -f .codex/config.toml
test -x tools/apply-profile.sh
test -x tools/audit-capabilities.sh

HOME="$TMP/home" tools/apply-profile.sh all >/dev/null
HOME="$TMP/home" tools/audit-capabilities.sh --expect-profile all >/dev/null

python3 -m json.tool .mcp.json >/dev/null
python3 -m json.tool .codex/hooks.json >/dev/null
grep -q '^\[mcp_servers.vercel\]' .codex/config.toml
grep -q '^\[mcp_servers.supabase\]' .codex/config.toml
grep -q '^\[mcp_servers.stripe\]' .codex/config.toml
grep -q '^\[mcp_servers.figma\]' .codex/config.toml

echo "Temp-project harness integration passed."
