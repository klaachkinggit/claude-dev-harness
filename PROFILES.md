# PROFILES.md — Per-Project Skill Packs

The base harness stays lean (under the ~8–12 skill ceiling where Claude's
skill-selection accuracy degrades). It ships **one** discovery skill —
`find-skills` — instead of bundling niche skills that would tax every session's
context whether you use them or not.

When you start a project, pull only the pack(s) that project needs. Use the
discovery skill or the direct install commands below.

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

## Rule of thumb

Audit every couple of weeks: for each installed skill, *did I use it?* If not,
remove it. Niche skills belong in the project that needs them — never in the base.
