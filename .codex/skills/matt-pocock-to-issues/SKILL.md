---
name: matt-pocock-to-issues
description: Use to convert a plan or PRD into vertical-slice GitHub issues with acceptance criteria.
---

# To Issues

Convert a plan into GitHub issues.

Rules:

- Use vertical slices only; each issue should deliver end-to-end value.
- Keep one focused session per issue; split anything larger.
- Make dependencies explicit with "Blocked by #X" when relevant.

Issue format:

```markdown
Title: [verb] [thing]

## Context
Why this exists.

## Acceptance criteria
- [ ] Specific, testable condition

## Out of scope
What this explicitly does not cover.
```

Output a numbered list ready to paste into GitHub. Confirm before creating issues via CLI.
