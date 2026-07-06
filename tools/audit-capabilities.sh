#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

EXPECTED_PROFILES=()

usage() {
  cat <<'EOF'
Usage:
  tools/audit-capabilities.sh [--expect-profile vercel|supabase|stripe|all]
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --expect-profile) EXPECTED_PROFILES+=("${2:-}"); shift 2 ;;
    --expect-profile=*) EXPECTED_PROFILES+=("${1#*=}"); shift ;;
    --check-user-resources) shift ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

failures=0
warnings=0

pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; failures=$((failures + 1)); }

check_file() {
  if [ -f "$1" ]; then pass "$1 exists"; else fail "$1 missing"; fi
}

check_absent() {
  if [ -e "$1" ]; then fail "$1 absent"; else pass "$1 absent"; fi
}

check_file AGENTS.md
check_file .codex/config.toml
check_file .codex/hooks.json
check_file .codex/hooks/protect-env.sh
check_file tools/gen-mcp.py
check_file tools/profile.py
check_file tools/finish-harness.sh

for path in CLAUDE.md .claude .mcp.json prompts RULES.md sync-rules.sh; do
  check_absent "$path"
done

if python3 -m json.tool .codex/hooks.json >/dev/null 2>&1; then
  pass ".codex/hooks.json is valid JSON"
else
  fail ".codex/hooks.json is invalid JSON"
fi

python3 - "${EXPECTED_PROFILES[@]-}" <<'PY'
import json
import re
import sys
from pathlib import Path

failures = []
expected_skills = {
    "find-skills",
    "superpowers",
    "grill-me",
    "tdd",
    "diagnosing-bugs",
    "to-issues",
    "codebase-design",
    "improve-codebase-architecture",
    "ponytail",
}
base = {"github", "git", "playwright", "sequential-thinking", "context7"}
profiles = set()
for item in sys.argv[1:]:
    if item == "all":
        profiles.update(["vercel", "supabase", "stripe"])
    elif item:
        profiles.add(item)

skills = {item.name for item in Path(".codex/skills").iterdir() if item.is_dir()} if Path(".codex/skills").exists() else set()
if skills != expected_skills:
    failures.append("expected Codex skills %s, got %s" % (", ".join(sorted(expected_skills)), ", ".join(sorted(skills))))

hooks = json.loads(Path(".codex/hooks.json").read_text())
commands = [
    hook.get("command", "")
    for blocks in hooks.get("hooks", {}).values()
    for block in blocks
    for hook in block.get("hooks", [])
]
if commands != ['bash "$(git rev-parse --show-toplevel)/.codex/hooks/protect-env.sh"']:
    failures.append("Codex hooks should only run protect-env.sh")

text = Path(".codex/config.toml").read_text()
codex = re.findall(r"^\[mcp_servers\.([^\].]+)\]", text, re.M)
codex_set = set(codex)
dupes = sorted(name for name in codex_set if codex.count(name) > 1)
if dupes:
    failures.append("duplicate Codex MCP sections: %s" % ", ".join(dupes))
for name in sorted(base):
    if name not in codex_set:
        failures.append("Codex base MCP missing: %s" % name)
forbidden_mcp = sorted({"filesystem"} & codex_set)
if forbidden_mcp:
    failures.append("Codex MCP must not include: %s" % ", ".join(forbidden_mcp))
if "claude" in text.lower():
    failures.append("Codex config should not reference Claude")

for name in sorted(profiles):
    if name not in {"vercel", "supabase", "stripe"}:
        failures.append("unknown expected profile: %s" % name)
    elif name not in codex_set:
        failures.append("Codex profile MCP missing: %s" % name)

if 'command = "uvx"' not in text:
    failures.append("Codex git MCP should use uvx")
if 'GITHUB_PERSONAL_ACCESS_TOKEN = "$GITHUB_TOKEN"' not in text:
    failures.append("Codex github MCP should map GITHUB_TOKEN")

for skill in expected_skills:
    path = Path(".codex/skills") / skill / "SKILL.md"
    if not path.exists():
        failures.append("%s missing" % path)
        continue
    content = path.read_text()
    if not content.startswith("---\n") or "\nname:" not in content or "\ndescription:" not in content:
        failures.append("%s missing frontmatter" % path)

for failure in failures:
    print("FAIL " + failure)
sys.exit(1 if failures else 0)
PY
status=$?
if [ "$status" -eq 0 ]; then
  pass "Codex capabilities match expected surface"
else
  failures=$((failures + 1))
fi

for script in tools/apply-profile.sh tools/remove-profile.sh tools/audit-capabilities.sh tools/check-agent-context.sh tools/check-profile.sh tools/preflight-harness.sh tools/finish-harness.sh tools/update-harness.sh; do
  if bash -n "$script"; then pass "$script syntax"; else fail "$script syntax"; fi
done
if [ -f apply.sh ]; then
  if bash -n apply.sh; then pass "apply.sh syntax"; else fail "apply.sh syntax"; fi
fi
for file in tools/*.py; do
  if python3 -m py_compile "$file" >/dev/null 2>&1; then pass "$file compiles"; else fail "$file compiles"; fi
done

printf '\n'
if [ "$failures" -gt 0 ]; then
  printf 'Capability audit failed: %s failure(s), %s warning(s)\n' "$failures" "$warnings"
  exit 1
fi

printf 'Capability audit passed: %s warning(s)\n' "$warnings"
