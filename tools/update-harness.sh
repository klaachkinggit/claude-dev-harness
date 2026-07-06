#!/usr/bin/env bash
set -euo pipefail

REPO="klaachkinggit/klaach_harness"
RAW="${HARNESS_RAW_BASE:-https://raw.githubusercontent.com/${REPO}/main}"
RAW="${RAW%/}"
DRY_RUN=0
RUN_PREFLIGHT=1

usage() {
  cat <<'EOF'
Usage:
  tools/update-harness.sh [--dry-run] [--no-preflight]

Updates harness-managed project-local files by re-running the remote apply.sh.
Do not clone the harness repo into the project.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --no-preflight)
      RUN_PREFLIGHT=0
      shift
      ;;
    *)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ "$DRY_RUN" = "1" ]; then
  printf 'Would update harness-managed files in %s\n' "$(pwd)"
  printf 'Source: %s/apply.sh\n' "$RAW"
  printf 'Command: HARNESS_RAW_BASE=%s bash <(curl -fsSL %s/apply.sh)\n' "$RAW" "$RAW"
  exit 0
fi

tmp="$(mktemp)"
cleanup() { rm -f "$tmp"; }
trap cleanup EXIT

curl -fsSL "${RAW}/apply.sh" > "$tmp"
HARNESS_RAW_BASE="$RAW" bash "$tmp"

if [ "$RUN_PREFLIGHT" = "1" ] && [ -x tools/preflight-harness.sh ]; then
  tools/preflight-harness.sh
fi
