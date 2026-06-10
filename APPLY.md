# Applying This Harness

> **For AI agents:** You are reading this because the user told you to use this harness. Follow the steps below exactly. Do not skip steps. Do not improvise the setup.

## Quick apply

Run from the project root:

```bash
TOOL=<your-tool> bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/claude-dev-harness/main/apply.sh)
```

Replace `<your-tool>` with one of: `claude` | `codex` | `cursor` | `windsurf` | `gemini` | `copilot` | `cline` | `all`

> Tool not listed? Use `TOOL=all`, then read [HARNESS.md](HARNESS.md) — it maps every layer to your tool's mechanism so you can finish wiring it up.

**Examples:**
```bash
# Claude Code
TOOL=claude bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/claude-dev-harness/main/apply.sh)

# Cursor
TOOL=cursor bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/claude-dev-harness/main/apply.sh)

# Unknown tool — copies everything
TOOL=all bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/claude-dev-harness/main/apply.sh)
```

## What gets applied

| Component | Files | Who reads it |
|-----------|-------|-------------|
| Behavioral rules | Tool-specific file (see below) | Your AI tool — auto-loaded |
| MCP server config | `.mcp.json` | Cursor, Windsurf, Claude Code, others |
| Prompt templates | `prompts/` | Paste into any tool |
| Slash commands | `.claude/commands/` | Claude Code only |
| Hook scripts | `.claude/hooks/` | Claude Code only |
| Settings | `.claude/settings.json` | Claude Code only |

## Rules file by tool

| Tool | Auto-loaded file |
|------|-----------------|
| Claude Code | `CLAUDE.md` |
| Cursor | `.cursorrules` + `.cursor/rules/harness.mdc` |
| Windsurf | `.windsurfules` |
| Gemini CLI | `GEMINI.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cline | `.clinerules` |
| Other | Copy contents of `RULES.md` into your system prompt |

## After applying — VERIFY (do not skip)

The setup can partially fail silently (missing token, network, CLI mismatch). `apply.sh` prints a `⚠️ Some setup steps FAILED` block if anything broke — **read it**. Then confirm:

1. **MCP servers** (Claude Code): run `claude mcp list` — confirm `github`, `filesystem`, `git`, `playwright` are listed. Empty list = setup failed; re-run after fixing `GITHUB_TOKEN`.
2. **Hooks** (Claude Code): run `ls .claude/hooks/` — confirm 5 `.sh` files present and executable.
3. **Env**: copy `.env.example` → `.env`, fill in `GITHUB_TOKEN` (and `DATABASE_URL` if using PostgreSQL).
4. **Overwrites**: if you had existing config, `apply.sh` saved it to `<file>.bak` — diff and merge anything you need back.

Then add project-specific rules at the bottom of your rules file (after the `<!-- Add project-specific rules below this line -->` comment).

## Per-project customization

Append to the bottom of your rules file:

```markdown
## Project: my-app

- Stack: [your stack]
- Test runner: [command]
- Lint: [command]
- Deploy: [how/where]
- [Any project-specific constraints]
```

## If curl is unavailable

```bash
gh repo clone klaachkinggit/claude-dev-harness /tmp/harness
# Then manually copy the files you need from /tmp/harness
```

## Hooks (Claude Code only)

The harness installs 5 hooks automatically:

| Hook | Event | What it does |
|------|-------|-------------|
| `protect-secrets.sh` | PreToolUse (Read/Write/Edit) | Blocks access to `.env`, `.pem`, `.key`, credentials files |
| `block-dangerous.sh` | PreToolUse (Bash) | Blocks `rm -rf /`, `curl\|bash`, force-push main, fork bombs |
| `log-bash.sh` | PreToolUse (Bash) | Appends every command to `.claude/bash.log` |
| `auto-format.sh` | PostToolUse (Edit/Write) | Runs prettier/black/ruff/gofmt if available |
| `pre-pr-gate.sh` | PreToolUse (GitHub PR create) | Blocks PR if tests are failing |
| Done notification | Stop | macOS notification or terminal bell when Claude finishes |
