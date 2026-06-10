# claude-dev-harness

Model-agnostic harness for AI-assisted software development. Works with Claude Code, Cursor, Windsurf, Gemini CLI, GitHub Copilot, Cline, and any other tool.

**Intended use:** point any AI agent at this repo and it self-installs into your project. See [APPLY.md](APPLY.md) for the full agent-facing setup guide.

## Quick apply

```bash
# Claude Code
TOOL=claude bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/claude-dev-harness/main/apply.sh)

# Cursor
TOOL=cursor bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/claude-dev-harness/main/apply.sh)

# All tools at once
TOOL=all bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/claude-dev-harness/main/apply.sh)
```

## What's included

### Behavioral rules
Canonical source: `RULES.md` → synced to all tool files via `sync-rules.sh`.

| Tool | Auto-loaded file |
|------|-----------------|
| Claude Code | `CLAUDE.md` |
| Cursor | `.cursorrules` + `.cursor/rules/harness.mdc` |
| Windsurf | `.windsurfules` |
| Gemini CLI | `GEMINI.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cline | `.clinerules` |
| Other | Copy `RULES.md` into system prompt |

### MCP servers (`.mcp.json` — cross-platform)
| Server | Purpose |
|--------|---------|
| `github` | Repo, PR, issue management |
| `filesystem` | Project file access |
| `git` | History, diff, blame, commit ops |
| `playwright` | Browser automation + E2E |
| `db` | PostgreSQL — optional, set `DATABASE_URL` |

### Plugins (Claude Code — installed by `apply.sh`)
| Plugin | Purpose |
|--------|---------|
| `obra/superpowers` | 7-phase production dev methodology, TDD-enforced |
| `mattpocock/skills` | Engineering discipline — /grill-me, /tdd, /diagnose, /zoom-out |
| `vercel-labs/agent-skills` | 100+ UI/a11y/perf rules |
| `anthropics/skills` | Frontend design + document generation |
| `trailofbits/skills` | Security scanning (CodeQL + Semgrep) |
| `JuliusBrussee/caveman` | 65–75% token reduction |

### Hooks (Claude Code — `.claude/hooks/`)
| Script | Trigger | What it does |
|--------|---------|-------------|
| `protect-secrets.sh` | PreToolUse Read/Write/Edit | Blocks access to `.env`, `.pem`, `.key`, credentials |
| `block-dangerous.sh` | PreToolUse Bash | Blocks `rm -rf /`, `curl\|bash`, force-push main, fork bombs |
| `log-bash.sh` | PreToolUse Bash | Appends every command to `.claude/bash.log` |
| `auto-format.sh` | PostToolUse Edit/Write | Runs prettier/black/ruff/gofmt if installed |
| `pre-pr-gate.sh` | PreToolUse create_pull_request | Blocks PR if tests fail |
| Done notification | Stop | macOS notification or terminal bell |

### Universal prompts (`prompts/`)
Paste into any tool — no tool-specific syntax.

| Prompt | When to use |
|--------|-------------|
| `grill-me.md` | Before any large implementation |
| `tdd.md` | Enforce RED-GREEN-REFACTOR |
| `diagnose.md` | Structured 8-step debugging |
| `to-issues.md` | PRD/plan → vertically-sliced GitHub issues |
| `zoom-out.md` | System map before unfamiliar code |
| `handoff.md` | Compact session → HANDOFF.md |
| `security-scan.md` | OWASP Top 10 + secrets check |
| `preflight.md` | Pre-ship checklist |

## Per-project customization

Add at the bottom of your rules file (below the `<!-- Add project-specific rules -->` line):

```markdown
## Project: my-app

- Stack: Next.js 14, Prisma, PostgreSQL
- Test runner: vitest — `npm test`
- Lint: eslint + prettier — `npm run lint`
- Deploy: Vercel, CI only — never deploy from local
- Schema changes require a migration file in `prisma/migrations/`
```

## Maintaining rules (harness maintainers only)

`RULES.md` is the single source. After editing it, regenerate every tool file:
```bash
./sync-rules.sh
```
This regenerates `GEMINI.md`, `AGENTS.md`, `.cursorrules`, `.windsurfules`, `.clinerules`, `.github/copilot-instructions.md`, `.cursor/rules/harness.mdc`, and `CLAUDE.md`. The Claude-specific additions live in `.claude-extra.md` and are appended to `CLAUDE.md` automatically — nothing diverges.

> Run `sync-rules.sh` **only in this harness repo**. In a target project you own the rules files and edit them freely — never run it there (it would overwrite your project rules). `apply.sh` backs up any file it would overwrite to `<file>.bak`.

## Environment variables

Copy `.env.example` → `.env`:
```
GITHUB_TOKEN=ghp_...          # required for GitHub MCP
DATABASE_URL=postgresql://... # optional, enables db MCP
```
