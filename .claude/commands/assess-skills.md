---
description: Assess what skills this project/feature needs, vet + install the useful ones, then build
allowed-tools: Read, Glob, Grep, Bash, Skill
argument-hint: <project or feature description>
---

Assess what skills are needed for: $ARGUMENTS — then install the useful ones and proceed.

1. **Identify needs** — list the concrete domains/tasks involved (e.g. browser/E2E testing, PDF/xlsx generation, DB migrations, auth, animation, scraping, mobile).
2. **Check coverage first** — skip anything the base already handles:
   - Workflow → Superpowers · Requirements → /grill-me · TDD → /tdd · Debug → /diagnose
   - Unfamiliar code → /zoom-out · Security → /security-scan · Ship gate → /preflight
   - Browser → Playwright MCP · Repo/PR → GitHub MCP · Secrets/format/tests → git hooks
   Do NOT add redundant skills.
3. **Find gaps** — for genuinely uncovered needs, invoke the `find-skills` skill or run `npx skills find "<need>"`; check skills.sh + PROFILES.md.
4. **Vet** — prefer 1K+ installs, official sources (vercel-labs/anthropics/microsoft), repo >100 stars. Reject paid-API/niche skills unless clearly needed.
5. **Install** only high-value, non-redundant skills, project-local. Keep total well under ~10.
6. **Report** what you added (and why) + what you skipped (already covered), then build.

Bias toward fewer skills. A base-harness prompt beats a new skill when they overlap.
