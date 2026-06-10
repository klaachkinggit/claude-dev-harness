# claude-dev-harness

Base Claude Code harness for software development. Clone for every new project, extend per-project at the bottom of `CLAUDE.md`.

## What's included

### `CLAUDE.md` — Behavioral contract
Karpathy's 3 foundational rules + engineering discipline. Applied every session, no config needed.

### MCP Servers
| Server | Purpose |
|--------|---------|
| `github` | Repo, PR, issue management |
| `filesystem` | Project file access |
| `git` | History, diff, blame, commit ops |
| `playwright` | Browser automation + E2E (Microsoft official) |
| `db` | PostgreSQL — optional, set `DATABASE_URL` |

### Plugins
| Plugin | Purpose |
|--------|---------|
| `obra/superpowers` | 7-phase production dev methodology, TDD-enforced |
| `mattpocock/skills` | Engineering discipline — grill-me, tdd, diagnose, zoom-out |
| `vercel-labs/agent-skills` | 100+ UI/a11y/perf rules (133K weekly installs) |
| `anthropics/skills` | Frontend design direction + Word/PDF/Excel generation |
| `trailofbits/skills` | Security scanning (CodeQL + Semgrep) |
| `JuliusBrussee/caveman` | 65–75% token reduction |

### Slash Commands (`.claude/commands/`)
| Command | When to use |
|---------|-------------|
| `/grill-me <task>` | Before any large implementation — exhaustive requirements interview |
| `/tdd <feature>` | Enforce RED-GREEN-REFACTOR |
| `/diagnose <bug>` | Structured 8-step debugging, no guess-fixing |
| `/to-issues <plan>` | Convert PRD/plan → vertically-sliced GitHub issues |
| `/zoom-out <area>` | System map before touching unfamiliar code |
| `/handoff` | Compact session → `HANDOFF.md` for continuation |
| `/security-scan <path>` | OWASP Top 10 + secrets exposure check |
| `/preflight` | Pre-ship checklist before every PR or deploy |

## Setup

### New project from this harness

```bash
# Option A — use as GitHub template (recommended)
gh repo create my-project --template klaachkinggit/claude-dev-harness --clone
cd my-project

# Option B — copy harness files into existing project
cp -r /path/to/claude-dev-harness/.claude .
cp /path/to/claude-dev-harness/CLAUDE.md .
```

### Install MCP servers + plugins

```bash
chmod +x install.sh
./install.sh

# With database:
DATABASE_URL="postgresql://user:pass@host:5432/db" ./install.sh
```

### Verify

```bash
claude mcp list
```

## Per-project customization

Add project-specific rules at the bottom of `CLAUDE.md`:

```markdown
## Project: my-app

- Stack: Next.js 14, Prisma, PostgreSQL
- Test runner: vitest — `npm test`
- Lint: eslint + prettier — `npm run lint`
- Deploy: Vercel — never deploy from local, use CI
- Schema changes require a migration file in `prisma/migrations/`
```

Add project-specific slash commands in `.claude/commands/`:

```markdown
---
description: Deploy to staging
allowed-tools: Bash
---
`vercel --target staging`
Report deploy URL and check for build errors.
```

## Principles

1. Start with `superpowers` + `mattpocock`. Add others as needed.
2. Extend `CLAUDE.md` at the bottom. Never delete foundational rules.
3. Review all hooks before enabling — they run with your credentials.
4. `/caveman ultra` default — saves ~65% tokens. Disable only for docs/explanations.
5. `/grill-me` before any non-trivial implementation. Slow down to go fast.
