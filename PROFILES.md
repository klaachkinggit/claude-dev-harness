# PROFILES.md — Per-Project Skill Packs

The base harness stays lean (under the ~8–12 skill ceiling where Claude's
skill-selection accuracy degrades). It ships **one** discovery skill —
`find-skills` — instead of bundling niche skills that would tax every session's
context whether you use them or not.

When you start a project, pull only the pack(s) that project needs. Use the
discovery skill or the direct install commands below.

## How this differs from `find-skills`
- **`find-skills` = discovery.** Live, ranked-by-installs search of the skills.sh
  registry. Use it to find *what exists* for a need.
- **This file = judgment.** What a leaderboard can't tell you: which skills
  **conflict** with the base, licensing/paid-API traps, and — most useful — the
  **"don't install" list** below. Curated, so it can go stale: treat it as a
  starting point, re-vet picks periodically, and prefer `find-skills` for current
  rankings.

## Don't install — the base already covers these
Adding these duplicates harness functionality and just taxes context. (Verified
against the r/ClaudeAI "best skills" thread + the harness's own layers.)

| If tempted to add… | Use instead (already in base) |
|--------------------|-------------------------------|
| a custom debug/root-cause skill (e.g. myclaude `dendrite`, `five-vitals`) | `diagnose`, `zoom-out` |
| a commit gate / secret scanner / formatter skill | the git hooks (`.githooks/`) + `security-scan` |
| a session-close / handoff skill (e.g. `/close`, Cabinet `handoff`) | `handoff` |
| an issue-creation / spec skill (Matt Pocock "QA Session") | `to-issues`, `grill-me` |
| caveman-style "token saver" skills | nothing — thread consensus: trims output only, not thinking ("meme skill") |
| context-engineering kits | redundant unless the *project itself* builds LLM agents |
| self-mutating / auto-tuning meta-skills (e.g. one-skill-to-rule-them-all) | overlaps harness hooks/memory; thread warns auto-mutation regresses quietly |
| a second workflow skill alongside Superpowers | swap, don't stack (see "Project workflow") |

## How to add skills to a project

**Via the discovery skill (any tool that supports skills):**
Just ask your agent: *"find a skill for X"* / *"is there a skill for testing web apps?"*
The `find-skills` skill checks the [skills.sh](https://skills.sh) leaderboard and
`npx skills find`, then installs the best match.

**Direct install (CLI):**
```bash
npx skills add <owner/repo@skill> -y       # project-local
npx skills add <owner/repo@skill> -g -y    # global
```

Quality bar before installing: prefer 1K+ installs, prefer official sources
(`vercel-labs`, `anthropics`, `microsoft`), treat <100-star repos skeptically.

## Profiles

### Web / frontend
For projects with a browser UI.
| Skill | Source | Why |
|-------|--------|-----|
| webapp-testing | `anthropics/skills@webapp-testing` | Playwright-driven E2E: launch server, drive browser, screenshots, console logs |
| ui-ux-pro-max | `nextlevelbuilder/ui-ux-pro-max-skill` | Design systems, color/font/layout reasoning |
| vercel agent-skills | `vercel-labs/agent-skills` | React/Next.js best practices, 100+ a11y/perf/UX rules |
| frontend-design | `anthropics/skills@frontend-design` | Sets bold design direction before coding |
| awesome-design-skills | `bergside/awesome-design-skills` | 57 visual-style skills (Neumorphism, Flat, Skeuomorphic…), MIT — add only the *one* style you're building in, not all 57 |

> Note: the base already includes a **Playwright MCP** server. `webapp-testing`
> is a workflow layer on top — add it only if MCP-level browser control isn't enough.

### Animation (subset of web)
| Skill | Source | Why |
|-------|--------|-----|
| gsap | `greensock/gsap-skills` | Correct GSAP/ScrollTrigger patterns — only if the project uses GSAP |

### Reporting / documents
For projects that generate files.
| Skill | Source | Why |
|-------|--------|-----|
| pdf | `anthropics/skills@pdf` | Generate/edit PDFs |
| xlsx | `anthropics/skills@xlsx` | Spreadsheets with formulas |
| docx | `anthropics/skills@docx` | Word docs with tracked changes |
| pptx | `anthropics/skills@pptx` | Presentations |

> License note: Anthropic's document skills are source-available, **not Apache-2.0**.
> Review the license before redistributing them inside a project.

### Data / scraping
For projects that ingest web data.
| Skill | Source | Why |
|-------|--------|-----|
| scrapegraph | `ScrapeGraphAI/just-scrape` | AI structured web extraction — needs a paid ScrapeGraph API key |

### AI / agent development
For projects that themselves build LLM agents.
| Skill | Source | Why |
|-------|--------|-----|
| skill-creator | `anthropics/skills@skill-creator` | Scaffold new skills |
| mcp-builder | `anthropics/skills@mcp-builder` | Build MCP servers |
| context-engineering | `muratcankoylan/Agent-Skills-for-Context-Engineering` | Context/prompt patterns (redundant with this harness for non-agent projects) |

## Project workflow — run exactly ONE

A "workflow" skill structures how the agent plans and implements. The base ships
**Superpowers** (`obra/superpowers`, installed by apply.sh) — the most-endorsed
option in the community. Do **not** run two workflow skills at once; they fight
over the same job. Swap, don't stack:

| Skill | Source | Fits |
|-------|--------|------|
| Superpowers *(default, in base)* | `obra/superpowers` | Small–medium, well-defined work; strong brainstorming → plan → execute |
| OpenSpec | `Fission-AI/OpenSpec` | Lightweight spec-driven build + rollback |
| GSD (Get-Shit-Done) | `gsd-build/get-shit-done` | Large, iterative projects; phased with heavy safety gates; `/gsd:map-codebase` onboarding |

Common pairing from the community: `grill-me` (pressure-test the idea) → workflow
skill (brainstorm → plan → implement). Both are compatible because grill-me is a
helper, not a workflow.

### Cross-runtime peer review (Claude + Codex)
You use both Claude Code and Codex — a community-endorsed pattern: have one build,
the other review. Different models catch different failure modes. No package needed;
just run `/review` (or paste the diff) in the *other* tool before merging.

## Skill hygiene (community-validated)
- One workflow skill at a time; small composable helpers around it.
- A skill's value is its **validators, hard-stops, and scripts** — not its prose.
  (This harness puts those at the git/CI layer so they hold under any tool.)
- Auto-updating skills is risky — a mutation can regress quietly. Keep stable skills frozen.
- Stale instruction files perform *worse* than none. Prune skills you haven't used in ~2 weeks.

## Rule of thumb

Audit every couple of weeks: for each installed skill, *did I use it?* If not,
remove it. Niche skills belong in the project that needs them — never in the base.
