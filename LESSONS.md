# LESSONS.md

Append-only log of heuristics learned. Read at session start alongside `MEMORY.md`. See `prompts/learn.md` for what goes in.

---

<!-- Append entries below. Format:

## YYYY-MM-DD — short title  [workflow|debug|test|arch|tools|prompt|cost]
- **Saw:** what happened (one line).
- **Why:** the underlying reason it worked / failed.
- **Next time:** the heuristic future-you will actually re-read.

-->

## 2026-06-16 — idempotent generated config  [tools]
- **Saw:** Codex MCP config kept an obsolete generated `git` server because `tools/gen-mcp.py` refused to update existing `mcp_servers`.
- **Why:** Manual-merge output is not a real harness fix; applied projects keep stale generated sections.
- **Next time:** Generators should replace their managed sections and preserve custom sections, not print blocks for humans to merge.

## 2026-06-16 — mirror behavior, not byte-for-byte files  [tools]
- **Saw:** Claude and Codex hook mirrors failed a strict diff even though provider-local paths legitimately differ.
- **Why:** Mirror parity means equivalent capability surfaces, not identical implementation text when providers need different wiring.
- **Next time:** Audits should compare shared names/contracts and then validate provider-specific config separately.

## 2026-06-17 — test applied projects, not only the harness repo  [test]
- **Saw:** The temp-project integration test caught that `audit-capabilities.sh` required `apply.sh`, which applied projects do not contain.
- **Why:** A harness repo can have maintenance files that target projects should not carry.
- **Next time:** Integration tests for harness tooling should run from a fresh applied project and distinguish maintenance-only files from installed files.
