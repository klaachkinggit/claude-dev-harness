# klaach_harness

Harness for AI-assisted software dev, built for **Claude Code + Codex CLI**. Rules/prompts stay portable, and all *enforcement* lives at the git+CI layer — so other tools still work. Provider files are intentionally mirrored for Claude and Codex; removed provider files live in git history, not an archive folder.

**Use:** point any agent at this repo; it self-installs. Setup → [APPLY.md](APPLY.md). Per-tool capability map → [HARNESS.md](HARNESS.md). Per-project skill/MCP/plugin packs → [PROFILES.md](PROFILES.md).

**Why it's model-agnostic:** rules + prompts are universal; MCP config is generated per-tool; all *enforcement* (no secrets, formatted code, passing tests) lives at the **git + CI layer**, so guarantees hold under any agent or human. Runtime hooks (Claude Code + Codex) are a faster copy of the same checks.

## Quick apply

```bash
# TOOL = claude | codex | all
TOOL=claude bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/klaach_harness/main/apply.sh)
```

## What's included

### Rules — behavioral contract
`RULES.md` is the single source, synced to every tool's file by `sync-rules.sh`.

| Tool | File |
|------|------|
| Claude Code | `CLAUDE.md` (= `RULES.md` + `.claude-extra.md`) |
| Codex | `AGENTS.md` |
| Other | copy `RULES.md` into the system prompt |

### Universal enforcement (git + CI — any tool or human)
- `.githooks/pre-commit` — block secrets, auto-format staged files
- `.githooks/pre-push` — run tests, block on failure
- `.github/workflows/ci.yml` — secret scan + lint + test on push/PR
- Activated by `apply.sh`: `git config core.hooksPath .githooks`

### MCP servers (per-tool config via `tools/gen-mcp.py`)
Base set: `github`, `filesystem`, `git` (`uvx mcp-server-git --repository .`), `playwright`, `sequential-thinking`, `context7`; `db` is added when `DATABASE_URL` is set. Emits the right format/path per tool (`.mcp.json` for Claude / `.codex/config.toml` for Codex). Stack-specific servers → [PROFILES.md](PROFILES.md).

### Code graph + token economy (CodeGraph)
Local symbol/call/import graph that both Claude Code & Codex can query over MCP instead of grep/read sweeps — ~−47% tokens, −58% tool calls, 100% local. Install once: `curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh`, then `codegraph init` per repo (`apply.sh` runs this if `codegraph` is on PATH). Machine-level MCP wiring via `codegraph install` is opt-in with `INSTALL_CODEGRAPH_MCP=1`. Token rules live in `RULES.md` → **Token economy**.

### Profiles (project-local optional MCPs)
`apply.sh` does not install user-level plugins or skills. Optional stack MCPs are added per project:

```bash
tools/apply-profile.sh vercel
tools/apply-profile.sh supabase
tools/apply-profile.sh stripe
tools/apply-profile.sh figma
tools/apply-profile.sh all --dry-run
tools/remove-profile.sh stripe
```

Use `tools/audit-capabilities.sh` to verify provider mirrors and MCP config. Add `--check-user-resources` only when you explicitly want it to inspect `~/.codex`, `~/.claude`, and `~/.agents`.

Useful installed-project checks:

```bash
tools/check-agent-context.sh --tool all
tools/check-profile.sh all
tools/preflight-harness.sh
tools/update-harness.sh --dry-run
```

### Hooks (Claude Code & Codex provider mirrors)
| Script | Trigger | Does |
|--------|---------|------|
| `project-scope.sh` | Read/Write/Edit/Bash | block direct file/path access outside the project root |
| `protect-secrets.sh` | Read/Write/Edit | block `.env`/`.pem`/`.key`/credentials (allows `*.example`) |
| `block-dangerous.sh` | Bash | recursive-rm of root/home/cwd, `curl\|sh`, force-push main, fork bomb — **+ rm/mv/truncate of `.env` & `git clean -f`** |
| `log-bash.sh` | Bash | log commands to provider-local log (`.claude/bash.log` or `.codex/bash.log`) |
| `auto-format.sh` | Edit/Write | prettier/black/ruff/gofmt if installed |
| `pre-pr-gate.sh` | create_pull_request | block PR if tests fail |
| done-notify | Stop | macOS notification / terminal bell |

Claude reads `.claude/settings.json` + `.claude/hooks/`; Codex reads
`.codex/hooks.json` + `.codex/hooks/`.

### Skills (lean by design)
Base bundles `find-skills` (discovers/installs any other on demand) plus a **front-end set** for UI work — `frontend-design`, `ui-ux-pro-max`, `impeccable`, `web-design-guidelines`, `awesome-design-md`. The same lean set is mirrored in `.claude/skills/` and `.codex/skills/`; keep those mirrors in sync. Matt Pocock-style routines (`grill-me`, `tdd`, `diagnose`, `zoom-out`, `to-issues`) live as portable prompts, not user-level skills. Niche skills are per-project — see [PROFILES.md](PROFILES.md). Skill descriptions tax every session's context, so the base stays minimal. Token discipline comes from CodeGraph, model-tier routing (`prompts/subagent.md`), `/compact`, and `/cost-review` — not from output-compression skills.

### Prompts (`prompts/` — paste into any tool)
`grill-me` (requirements interview), `sparc` (5-phase build), `tdd` (RED-GREEN-REFACTOR), `diagnose` (8-step debug), `to-issues` (plan → issues), `zoom-out` (system map), `security-scan` (OWASP + secrets + PII), `risk-review` (diff risk classifier), `preflight` (pre-ship checklist), `audit` (periodic repo health), `adr` (architecture decision record), `memorize` (append to `MEMORY.md`), `learn` (append to `LESSONS.md`), `subagent` (when to delegate + Haiku/Sonnet/Opus tier routing), `cost-review` (token/spend check), `assess-capabilities` (acquire skills/MCP/plugins for a project/feature), `adopt-harness` (adopt into existing project + clean up). Claude gets thin `.claude/commands/` wrappers; Codex uses the shared `prompts/` bodies.

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
Edit `RULES.md`, then `./sync-rules.sh` regenerates all tool files (`CLAUDE.md` = `RULES.md` + `.claude-extra.md`). Run `./sync-rules.sh --check` to verify generated files are current without mutating them. Run it **only here** — in a target project you own the rules files. `apply.sh` backs up overwrites to `<file>.bak`.

Run `tools/preflight-harness.sh` before changing `apply.sh` or profile tooling. In this repo it also runs `tools/test-harness-integration.sh`, which applies the harness into a temporary git repo from a local `file://` source, preserves pre-existing Claude/Codex custom MCP config and project rules, applies/removes optional MCP profiles, checks dry-run behavior, and runs the capability audit there. CI runs the same blocking preflight on every push and pull request.

## Env
Copy `.env.example` → `.env`: `GITHUB_TOKEN` (required for github MCP), `DATABASE_URL` (optional, enables db MCP).
