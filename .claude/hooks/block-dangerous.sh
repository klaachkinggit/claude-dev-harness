#!/usr/bin/env bash
# Blocks known-dangerous shell patterns. Exit 2 = hard block.
INPUT=$(cat)
CMD=$(python3 - <<'EOF'
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
EOF
<<< "$INPUT" 2>/dev/null || echo "")

[ -z "$CMD" ] && exit 0

# Patterns: [description] = regex
declare -A PATTERNS=(
  ["rm -rf on / or ~"]='rm[[:space:]]+-[rRfF]+[[:space:]]+[/~]'
  ["rm -rf *"]='rm[[:space:]]+-[rRfF]+[[:space:]]+\*'
  ["sudo rm"]='sudo[[:space:]]+rm'
  ["fork bomb"]=':\(\)[[:space:]]*\{'
  ["chmod 777"]='chmod[[:space:]]+[0-9]*777'
  ["dd to disk"]='dd[[:space:]]+if=.*of=/dev/'
  ["write to disk device"]='>[[:space:]]*/dev/s[dh][a-z]'
  ["mkfs"]='mkfs\.'
  ["pipe to shell"]='[|][[:space:]]*(ba)?sh[[:space:]]*$'
  ["force push main/master"]='git[[:space:]]+push[[:space:]].*--force[^-]*(main|master)'
)

for desc in "${!PATTERNS[@]}"; do
  if echo "$CMD" | grep -qE "${PATTERNS[$desc]}"; then
    echo "BLOCKED: $desc" >&2
    exit 2
  fi
done
exit 0
