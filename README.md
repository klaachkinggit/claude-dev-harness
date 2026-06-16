# klaach_harness

Model-agnostic harness for AI-assisted software dev. Works with Claude Code, Codex CLI, Cursor, Windsurf, Gemini CLI, Copilot, Cline, and any future tool.

**Use:** point any agent at this repo; it self-installs. Setup → [APPLY.md](APPLY.md). Per-tool capability map → [HARNESS.md](HARNESS.md). Per-project skill/MCP/plugin packs → [PROFILES.md](PROFILES.md).

**Why it's model-agnostic:** rules + prompts are universal; MCP config is generated per-tool; all *enforcement* (no secrets, formatted code, passing tests) lives at the **git + CI layer**, so guarantees hold under any agent or human. Runtime hooks (Claude Code + Codex) are a faster copy of the same checks.

## Quick apply

```bash
# TOOL = claude | codex | cursor | windsurf | gemini | copilot | cline | all
TOOL=claude bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/klaach_harness/main/apply.sh)
```

## What's included

### Rules — behavioral contract
`RULES.md` is the single source, synced to every tool's file by `sync-rules.sh`.

| Tool | File | | Tool | File |
|------|------|-|------|------|
| Claude Code | `CLAUDE.md` | | Gemini | `GEMINI.md` |
| Codex | `AGENTS.md` | | Copilot | `.github/copilot-instructions.md` |
| Cursor | `.cursorrules` + `.cursor/rules/harness.mdc` | | Cline | `.clinerules` |
| Windsurf | `.windsurfules` | | Other | copy `RULES.md` into system prompt |

### Universal enforcement (git + CI — any tool or human)
- `.githooks/pre-commit` — block secrets, auto-format staged files
- `.githooks/pre-push` — run tests, block on failure
- `.github/workflows/ci.yml` — secret scan + lint + test on push/PR
- Activated by `apply.sh`: `git config core.hooksPath .githooks`

### MCP servers (per-tool config via `tools/gen-mcp.py`)
Base set: `github`, `filesystem`, `git`, `playwright`, `sequential-thinking`, `db` (Postgres, set `DATABASE_URL`). Emits the right format/path per tool (`.mcp.json` / `.cursor/mcp.json` / `.codex/config.toml`). Stack-specific servers → [PROFILES.md](PROFILES.md).

### Plugins (Claude Code — installed by `apply.sh`)
`obra/superpowers` (workflow), `DietrichGebert/ponytail` (minimalist/token-discipline guardrails), `upstash/context7` (current library docs), `anthropics/skills` → `claude-api` + `document-skills` (Anthropic SDK + PDF/docx/xlsx/pptx). The `trailofbits/skills` marketplace is also registered so you can `claude plugin install <name>@trailofbits` on demand (it ships ~19 security plugins — opt-in to avoid bloat). Codex gets `ponytail` and `context7` through its plugin marketplace.

### Hooks (Claude Code & Codex — `.claude/hooks/`)
| Script | Trigger | Does |
|--------|---------|------|
| `protect-secrets.sh` | Read/Write/Edit | block `.env`/`.pem`/`.key`/credentials |
| `block-dangerous.sh` | Bash | block recursive-rm of root/home/cwd, `curl\|sh`, force-push main, fork bomb |
| `log-bash.sh` | Bash | log commands to `.claude/bash.log` |
| `auto-format.sh` | Edit/Write | prettier/black/ruff/gofmt if installed |
| `pre-pr-gate.sh` | create_pull_request | block PR if tests fail |
| done-notify | Stop | macOS notification / terminal bell |

### Skills (lean by design)
Base bundles only `find-skills` (discovers/installs any other skill on demand). Niche skills are per-project — see [PROFILES.md](PROFILES.md). Skill descriptions tax every session's context, so the base stays minimal. Token discipline comes from model-tier routing (`prompts/subagent.md`), `/compact`, and `/cost-review` — not from output-compression skills.

### Prompts (`prompts/` — paste into any tool)
`grill-me` (requirements interview), `sparc` (5-phase build), `tdd` (RED-GREEN-REFACTOR), `diagnose` (8-step debug), `to-issues` (plan → issues), `zoom-out` (system map), `security-scan` (OWASP + secrets + PII), `risk-review` (diff risk classifier), `preflight` (pre-ship checklist), `audit` (periodic repo health), `adr` (architecture decision record), `memorize` (append to `MEMORY.md`), `learn` (append to `LESSONS.md`), `subagent` (when to delegate + Haiku/Sonnet/Opus tier routing), `cost-review` (token/spend check), `assess-capabilities` (acquire skills/MCP/plugins for a project/feature), `adopt-harness` (adopt into existing project + clean up). Claude/Codex get the same as `/slash` commands.

### Memory, decisions & learning
- `MEMORY.md` — append-only cross-session memory (state of the world). See `prompts/memorize.md`.
- `LESSONS.md` — append-only heuristics learned (what to do next time). See `prompts/learn.md`. Together these are the portable "self-learning" loop: read at session start, append when something non-obvious happens. No daemon, no vector DB.
- `docs/adr/` — architecture decision records (template at `0000-template.md`, write via `prompts/adr.md`).

## Per-project customization
Append below the `<!-- Add project-specific rules -->` line in your rules file:
```markdown
## Project: my-app
- Stack: Next.js 14, Prisma, PostgreSQL
- Test: vitest — `npm test` · Lint: `npm run lint`
- Deploy: Vercel, CI only — never from local
```

## Maintaining (harness repo only)
Edit `RULES.md`, then `./sync-rules.sh` regenerates all tool files (`CLAUDE.md` = `RULES.md` + `.claude-extra.md`). Run it **only here** — in a target project you own the rules files. `apply.sh` backs up overwrites to `<file>.bak`.

## Env
Copy `.env.example` → `.env`: `GITHUB_TOKEN` (required for github MCP), `DATABASE_URL` (optional, enables db MCP).
