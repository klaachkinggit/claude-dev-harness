# Applying This Harness

> **For AI agents:** You are reading this because the user told you to use this harness. Follow the steps below exactly. Do not skip steps. Do not improvise the setup.

## Quick apply

Run from the project root:

```bash
TOOL=<your-tool> bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/claude-dev-harness/main/apply.sh)
```

Replace `<your-tool>` with one of: `claude` | `cursor` | `windsurf` | `gemini` | `copilot` | `cline` | `all`

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

## After applying

1. Add project-specific rules at the bottom of your rules file (after the `<!-- Add project-specific rules below this line -->` comment)
2. Copy `.env.example` → `.env` and fill in `GITHUB_TOKEN`
3. Set `DATABASE_URL` in `.env` if using PostgreSQL
4. For Claude Code: run `claude mcp list` to verify MCP servers are registered

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
