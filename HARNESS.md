# HARNESS.md — Capability Map (for agents)

> **AI agent told to use this repo as a harness? Read this.** It maps each layer
> to *your* tool's mechanism. Tool not listed → use the generic row and adapt.

## Mental model — layers
Universal layers work everywhere. Tool-specific layers: the *protection* is
universal, the *mechanism* differs. **Principle:** anything enforceable at the
git/CI layer is, so guarantees hold under any agent or human; runtime hooks are
a faster copy for tools that support them.

| Layer | Does | Universal? |
|-------|------|-----------|
| Rules | behavioral contract | ✅ content universal, filename per tool |
| Prompts | workflow templates | ✅ plain markdown |
| MCP | tool/data servers | ⚠️ same servers, config/path per tool |
| Git hooks + CI | block secrets, format, gate tests | ✅ any tool or human |
| Runtime hooks | block dangerous cmds/secrets mid-session | ❌ Claude Code + Codex only |
| Slash commands | prompts as `/commands` | ❌ Claude Code + Codex only |
| Plugins | curated packs | ❌ Claude Code only |

## Rules file — where your tool reads instructions
Same content (`RULES.md`, synced by `sync-rules.sh`); filename + MCP env-var syntax differ.

| Tool | File | MCP env-var syntax |
|------|------|--------------------|
| Claude Code | `CLAUDE.md` | `${VAR}` |
| Codex CLI | `AGENTS.md` | none — forward by name (`env_vars`) |
| Cursor | `.cursorrules` + `.cursor/rules/*.mdc` | `${env:VAR}` |
| Windsurf | `.windsurfules` | `${env:VAR}` |
| Gemini CLI | `GEMINI.md` | `$VAR` |
| Copilot | `.github/copilot-instructions.md` | n/a (VS Code) |
| Cline | `.clinerules` | varies |
| Not listed? | copy `RULES.md` into your system prompt | check your docs |

## MCP — getting servers into your tool
`tools/gen-mcp.py` is the single source; it emits the right format/path:
```bash
python3 tools/gen-mcp.py claude    # → .mcp.json           (root)
python3 tools/gen-mcp.py cursor    # → .cursor/mcp.json
python3 tools/gen-mcp.py codex     # → .codex/config.toml  (TOML)
python3 tools/gen-mcp.py windsurf  # → prints ~/.codeium/windsurf/mcp_config.json snippet
python3 tools/gen-mcp.py gemini    # → prints ~/.gemini/settings.json snippet
```
Base servers: `github`, `filesystem`, `git`, `playwright`, `sequential-thinking`, `db` (if `DATABASE_URL` set).
Tool not an emitter → translate `.mcp.json` (generic JSON) to your tool's format; adding an emitter is one function in `gen-mcp.py`. Stack-specific servers (Vercel, Docker, Stripe, …) → PROFILES.md, or discover live via `registry.modelcontextprotocol.io` / awesome-mcp-servers / mcp.so / Smithery / PulseMCP. Don't re-add the base 5.

## Runtime hooks — Claude Code & Codex
Shared scripts in `.claude/hooks/` read the tool-call as JSON on stdin, exit `2` to block.
- **Claude Code:** wired in `.claude/settings.json`.
- **Codex:** wired in `.codex/hooks.json` (same scripts).
- **⚠️ Codex caveat:** scripts expect `tool_input.command` / `tool_input.file_path`. Codex's schema mirrors Claude's but field names may differ by version — **test with a known-bad command first**; if the field is absent the scripts **fail open** (no block).
- **Other tools (no hook system):** no runtime blocking — the git hooks cover the same ground at commit/push.

| Script | Blocks / does |
|--------|--------------|
| `block-dangerous.sh` | recursive rm of root/home/cwd, `curl\|sh`, force-push main, fork bomb, mkfs, dd-to-disk |
| `protect-secrets.sh` | read/write/edit of `.env`/`.pem`/`.key`/credentials |
| `auto-format.sh` | prettier/black/ruff/gofmt/rustfmt on edited files |
| `log-bash.sh` | logs commands to `.claude/bash.log` |
| `pre-pr-gate.sh` | blocks PR if tests fail |

## Git + CI — universal enforcement (every tool, every human)
- `.githooks/pre-commit` — block secrets, auto-format staged files.
- `.githooks/pre-push` — run tests, block on failure.
- `.github/workflows/ci.yml` — secret scan + lint + test on push/PR.
- Activate: `git config core.hooksPath .githooks` (apply.sh does it). Bypass once: `--no-verify`.

This is *why* the harness is model-agnostic on enforcement: the guarantees hold at git/CI regardless of which agent (or human) wrote the code.

## Skills — lean on purpose
Descriptions load into context every session (past ~1% of the window they truncate + mis-activate). Base bundles only `find-skills` (installs any other skill on demand). Everything else is per-project — see PROFILES.md, or ask *"find a skill for X"*. Prune skills unused for ~2 weeks.

Token discipline comes from the **lean-skills rule above**, `/compact` between work phases, `prompts/subagent.md`'s **model tier routing** (Haiku/Sonnet/Opus per task), Ponytail's YAGNI pressure, and `/cost-review` — *not* from output-compression skills (see PROFILES.md "Don't install").

## Prompts
`prompts/*.md` — plain markdown, paste anywhere; or `/slash` commands in Claude/Codex (Codex: drop into `~/.codex/prompts/`). List in README.

## Brand-new tool with none of these mechanisms?
Minimum viable adoption, in order:
1. Load `RULES.md` as system instructions. *(behavior)*
2. Translate `.mcp.json` to your MCP config. *(capabilities)*
3. Set `git config core.hooksPath .githooks`. *(enforcement — the safety net that needs no tool features)*
4. Use `prompts/*.md` as templates.

That's 80% of the value with zero tool-specific features.
