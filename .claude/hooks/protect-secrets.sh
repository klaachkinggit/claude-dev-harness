#!/usr/bin/env bash
# Blocks Read/Write/Edit on sensitive files. Exit 2 = hard block.
INPUT=$(cat)
FILE=$(python3 -c "
import sys, json
d = json.loads('$INPUT'.replace(\"'\", \"'\") if False else sys.stdin.read() if False else '')
" 2>/dev/null <<< "$INPUT" || echo "")

FILE=$(python3 - <<'EOF'
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('file_path', '') or d.get('tool_input', {}).get('path', ''))
EOF
<<< "$INPUT" 2>/dev/null || echo "")

[ -z "$FILE" ] && exit 0

PATTERNS=(
  '\.env$' '\.env\.' '\.pem$' '\.key$' '\.p12$' '\.pfx$'
  'id_rsa' 'id_ed25519' 'id_ecdsa'
  'credentials\.json$' '\.netrc$' 'secrets\.'
)

for pat in "${PATTERNS[@]}"; do
  if echo "$FILE" | grep -qE "$pat"; then
    echo "BLOCKED: sensitive file — $FILE" >&2
    exit 2
  fi
done
exit 0
