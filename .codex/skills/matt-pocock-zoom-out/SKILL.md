---
name: matt-pocock-zoom-out
description: Use before editing an unfamiliar area to map entry points, dependencies, data flow, side effects, and tests.
---

# Zoom Out

Before touching an unfamiliar area, build a concise system map.

Include:

1. Entry points: routes, events, CLI commands, jobs, or user actions.
2. Dependencies: imports and callers.
3. Data shapes: key types, schemas, interfaces, and payloads.
4. Side effects: database, files, network, events, or cache writes.
5. Test coverage: current tests and gaps.
6. Recent changes: relevant `git log --oneline -20 -- <path>`.
7. Known issues: TODOs, FIXMEs, warnings, or brittle code.

Highlight anything surprising or risky before editing.
