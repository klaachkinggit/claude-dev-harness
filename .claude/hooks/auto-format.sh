#!/usr/bin/env bash
# Auto-format after Edit/Write. Graceful no-op if formatter not installed.
INPUT=$(cat)
FILE=$(python3 - <<'EOF'
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('file_path', ''))
EOF
<<< "$INPUT" 2>/dev/null || echo "")

[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

EXT="${FILE##*.}"

case "$EXT" in
  js|jsx|ts|tsx|css|scss|json|html|md|yaml|yml)
    # Try local prettier first, then global
    if [ -x "$(pwd)/node_modules/.bin/prettier" ]; then
      "$(pwd)/node_modules/.bin/prettier" --write "$FILE" --loglevel silent 2>/dev/null || true
    elif command -v prettier >/dev/null 2>&1; then
      prettier --write "$FILE" --loglevel silent 2>/dev/null || true
    fi
    ;;
  py)
    command -v ruff >/dev/null 2>&1 && ruff format "$FILE" --quiet 2>/dev/null || true
    command -v black >/dev/null 2>&1 && black "$FILE" --quiet 2>/dev/null || true
    ;;
  go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE" 2>/dev/null || true
    ;;
  rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE" 2>/dev/null || true
    ;;
esac

exit 0
