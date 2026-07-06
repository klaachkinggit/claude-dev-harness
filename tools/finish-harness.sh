#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

if [ -x tools/preflight-harness.sh ]; then
  tools/preflight-harness.sh
else
  echo "finish gate failed: tools/preflight-harness.sh is missing or not executable" >&2
  exit 1
fi

dirty="$(git status --short --untracked-files=all)"
if [ -n "$dirty" ]; then
  echo "finish gate failed: worktree is dirty" >&2
  printf '%s\n' "$dirty" >&2
  echo "Commit verified work or explicitly document why the tree must remain dirty." >&2
  exit 1
fi

echo "Finish gate passed."
