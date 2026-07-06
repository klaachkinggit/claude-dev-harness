#!/usr/bin/env bash
set -u

failures=0
warnings=0

pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; failures=$((failures + 1)); }

check_file() {
  if [ -f "$1" ]; then pass "$1 exists"; else fail "$1 missing"; fi
}

check_dir() {
  if [ -d "$1" ]; then pass "$1 exists"; else fail "$1 missing"; fi
}

check_text() {
  local file="$1" pattern="$2" label="$3"
  if [ -f "$file" ] && grep -q "$pattern" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

for path in .claude CLAUDE.md .mcp.json prompts RULES.md sync-rules.sh; do
  if [ -e "$path" ]; then
    fail "$path should not exist in Codex-only harness"
  else
    pass "$path absent"
  fi
done

check_file AGENTS.md
check_file .codex/config.toml
check_file .codex/hooks.json
check_file .codex/hooks/protect-env.sh
check_dir .codex/skills
check_file APPLY.md
check_file HARNESS.md
check_file PROFILES.md

check_text AGENTS.md "Foundational Rules (Karpathy)" "AGENTS.md keeps Karpathy rules"
check_text AGENTS.md "ponytail" "AGENTS.md references Ponytail"
check_text AGENTS.md "sequential-thinking" "AGENTS.md references sequential-thinking"
check_text AGENTS.md "context7" "AGENTS.md references context7"

python3 - <<'PY'
import json
import re
import sys
from pathlib import Path

failures = []
expected_skills = {
    "find-skills",
    "superpowers",
    "matt-pocock-grill-me",
    "matt-pocock-tdd",
    "matt-pocock-diagnose",
    "matt-pocock-zoom-out",
    "matt-pocock-to-issues",
    "ponytail",
}
base_mcp = {"github", "filesystem", "git", "playwright", "sequential-thinking", "context7"}

got = {item.name for item in Path(".codex/skills").iterdir() if item.is_dir()} if Path(".codex/skills").exists() else set()
if got != expected_skills:
    failures.append(".codex/skills expected %s, got %s" % (", ".join(sorted(expected_skills)), ", ".join(sorted(got))))

hooks = json.loads(Path(".codex/hooks.json").read_text())
commands = [
    hook.get("command", "")
    for blocks in hooks.get("hooks", {}).values()
    for block in blocks
    for hook in block.get("hooks", [])
]
if commands != ['bash "$(git rev-parse --show-toplevel)/.codex/hooks/protect-env.sh"']:
    failures.append(".codex/hooks.json should only run protect-env.sh")

text = Path(".codex/config.toml").read_text() if Path(".codex/config.toml").exists() else ""
servers = set(re.findall(r"^\[mcp_servers\.([^\].]+)\]", text, re.M))
missing = sorted(base_mcp - servers)
if missing:
    failures.append("Codex MCP missing: %s" % ", ".join(missing))
if "figma" in servers:
    failures.append("Figma profile should not be present")

for skill in sorted(expected_skills):
    path = Path(".codex/skills") / skill / "SKILL.md"
    if not path.exists():
        failures.append("%s missing" % path)
        continue
    content = path.read_text()
    if not content.startswith("---\n") or "\nname:" not in content or "\ndescription:" not in content:
        failures.append("%s missing skill frontmatter" % path)

for failure in failures:
    print("FAIL " + failure)
sys.exit(1 if failures else 0)
PY
status=$?
if [ "$status" -eq 0 ]; then
  pass "Codex skill, hook, and MCP surfaces present"
else
  failures=$((failures + 1))
fi

printf '\n'
if [ "$failures" -gt 0 ]; then
  printf 'Agent context check failed: %s failure(s), %s warning(s)\n' "$failures" "$warnings"
  exit 1
fi

printf 'Agent context check passed: %s warning(s)\n' "$warnings"
