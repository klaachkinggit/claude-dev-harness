# claude-dev-harness

Model-agnostic base harness for AI-assisted software development. Works with Claude Code, Cursor, Windsurf, Gemini CLI, GitHub Copilot, Cline, and any other tool. Clone for every project, extend per-project at the bottom of the rules file.

## Compatibility

| Tool | Rules file | MCP | Prompts |
|------|-----------|-----|---------|
| Claude Code | `CLAUDE.md` (auto) | `claude mcp add` + plugins | `.claude/commands/` slash commands |
| Cursor | `.cursorrules` + `.cursor/rules/` (auto) | `.mcp.json` | `prompts/` |
| Windsurf | `.windsurfules` (auto) | `.mcp.json` | `prompts/` |
| Gemini CLI | `GEMINI.md` (auto) | `.mcp.json` | `prompts/` |
| GitHub Copilot | `.github/copilot-instructions.md` (auto) | VS Code MCP extension | `prompts/` |
| Cline | `.clinerules` (auto) | `.mcp.json` | `prompts/` |
| Other | Copy `RULES.md` into system prompt | `.mcp.json` | `prompts/` |

## What's included

### Behavioral rules
One canonical source (`RULES.md`) — Karpathy's 3 foundational LLM coding rules + engineering discipline. Auto-populated into every tool's expected file. No config needed.

### MCP Servers (`.mcp.json`)
| Server | Purpose |
|--------|---------|
| `github` | Repo, PR, issue management |
| `filesystem` | Project file access |
| `git` | History, diff, blame, commit ops |
| `playwright` | Browser automation + E2E (Microsoft official) |
| `db` | PostgreSQL — optional, set `DATABASE_URL` |

### Plugins (Claude Code only, via `install.sh`)
| Plugin | Purpose |
|--------|---------|
| `obra/superpowers` | 7-phase production dev methodology, TDD-enforced |
| `mattpocock/skills` | Engineering discipline — /grill-me, /tdd, /diagnose, /zoom-out |
| `vercel-labs/agent-skills` | 100+ UI/a11y/perf rules (133K weekly installs) |
| `anthropics/skills` | Frontend design direction + Word/PDF/Excel generation |
| `trailofbits/skills` | Security scanning (CodeQL + Semgrep) |
| `JuliusBrussee/caveman` | 65–75% token reduction |

### Universal prompts (`prompts/`)
Paste into any AI tool — no tool-specific syntax.

| Prompt | When to use |
|--------|-------------|
| `grill-me.md` | Before any large implementation — exhaustive requirements interview |
| `tdd.md` | Enforce RED-GREEN-REFACTOR |
| `diagnose.md` | Structured 8-step debugging, no guess-fixing |
| `to-issues.md` | Convert PRD/plan → vertically-sliced GitHub issues |
| `zoom-out.md` | System map before touching unfamiliar code |
| `handoff.md` | Compact session → `HANDOFF.md` for continuation |
| `security-scan.md` | OWASP Top 10 + secrets exposure check |
| `preflight.md` | Pre-ship checklist before every PR or deploy |

### Claude Code slash commands (`.claude/commands/`)
Same prompts wired as `/grill-me`, `/tdd`, `/diagnose`, etc. — auto-available in Claude Code sessions.

## Setup

### New project from this harness

```bash
# Use as GitHub template (recommended)
gh repo create my-project --template klaachkinggit/claude-dev-harness --clone
cd my-project
./install.sh
```

### Install for your tool

```bash
chmod +x install.sh
./install.sh
# Select your tool from the menu

# With database:
DATABASE_URL="postgresql://user:pass@host:5432/db" ./install.sh
```

## Per-project customization

Add project rules at the bottom of your tool's rules file (e.g., `CLAUDE.md`, `.cursorrules`):

```markdown
## Project: my-app

- Stack: Next.js 14, Prisma, PostgreSQL
- Test runner: vitest — `npm test`
- Lint: eslint + prettier — `npm run lint`
- Deploy: Vercel — use CI, never deploy from local
- Schema changes require a migration file in `prisma/migrations/`
```

## Principles

1. Pick one prompt, learn it, add the next. Don't overwhelm the context.
2. Extend rules at the bottom — never delete foundational rules.
3. Review any hooks before enabling — they run with your credentials.
4. `grill-me` before any non-trivial implementation. Slow down to go fast.
