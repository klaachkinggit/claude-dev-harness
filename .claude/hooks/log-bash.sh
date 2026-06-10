#!/usr/bin/env bash
# Appends every bash command to .claude/bash.log with UTC timestamp.
INPUT=$(cat)
CMD=$(python3 - <<'EOF'
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', 'unknown'))
EOF
<<< "$INPUT" 2>/dev/null || echo "unknown")

LOG="${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/bash.log"
printf '%s  %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$CMD" >> "$LOG" 2>/dev/null
exit 0
