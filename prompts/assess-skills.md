# Assess Skills — acquire the right skills before building

Use at **project kickoff** (describe the project) or **before any non-trivial
feature** (describe the feature). Goal: pull in skills that genuinely help, skip
everything the base already covers, and keep the set lean.

## Input
A description of the project, or the feature about to be built.

## Steps
1. **Identify needs** — list the concrete domains/tasks this work involves
   (e.g. browser/E2E testing, PDF or spreadsheet generation, DB migrations,
   auth flows, animation, web scraping, mobile).
2. **Check coverage first** — for each need, is it already handled by the base?
   - Workflow → Superpowers · Requirements → grill-me · TDD → tdd · Debug → diagnose
   - Unfamiliar code → zoom-out · Security → security-scan · Ship gate → preflight
   - Browser → Playwright MCP · Repo/PR → GitHub MCP · Secrets/format/tests → git hooks
   - Discovery → find-skills (see HARNESS.md / PROFILES.md)
   **Skip anything already covered — do NOT add redundant skills.**
3. **Find gaps** — only for genuinely uncovered needs, use the `find-skills`
   skill or run `npx skills find "<need>"`; check the skills.sh leaderboard and
   PROFILES.md profiles (web / reporting / scraping / animation / agent-dev).
4. **Vet before installing** — prefer 1K+ installs, official sources
   (vercel-labs, anthropics, microsoft), repo >100 stars. Reject paid-API or
   niche skills unless this project clearly needs them. Skills are text — read
   one if unsure.
5. **Install only high-value, non-redundant skills**, project-local (not global).
   Keep the total well under ~10 — skill descriptions tax context every session.
6. **Report, then build** — state what you added and why, what you skipped
   (already covered), then proceed with the work.

## Guardrails
- Bias toward fewer skills. A base-harness prompt beats a new skill when they overlap.
- Never install an unvetted skill.
- This is an assessment, not a shopping spree — if the base covers it, add nothing.
