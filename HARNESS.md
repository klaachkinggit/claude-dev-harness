# HARNESS.md - Codex Capability Map

## Layers

| Layer | Path | Purpose |
| --- | --- | --- |
| Rules | `AGENTS.md` | Codex behavior contract |
| MCP | `.codex/config.toml` | Local and hosted tool servers |
| Runtime hook | `.codex/hooks.json`, `.codex/hooks/protect-env.sh` | Block exact `.env` mutation |
| Skills | `.codex/skills/` | On-demand workflows and rules |
| Git + CI | `.githooks/`, `.github/workflows/ci.yml` | Tool-independent enforcement |
| Memory | `MEMORY.md`, `LESSONS.md`, `docs/adr/` | Durable project context |
| Agent map | `docs/agent-work-environment.md` | Source ownership, ignored state, verification, finish gate |

## Codex MCP

Generate base config:

```bash
python3 tools/gen-mcp.py codex
```

Base servers:

- `github`
- `git`
- `playwright`
- `sequential-thinking`
- `context7`
- `db` when `DATABASE_URL` is set

Optional profiles:

- `vercel`
- `supabase`
- `stripe`

Use:

```bash
tools/apply-profile.sh vercel
tools/remove-profile.sh stripe
tools/check-profile.sh all
```

## Runtime Hook

Only `.codex/hooks/protect-env.sh` is installed. It blocks Codex write/edit/shell mutation of exact `.env` and allows `.env.example`, `.env.sample`, and other non-exact template names.

## Skills

Installed by the base harness:

- `find-skills`
- `superpowers`
- `grill-me`
- `tdd`
- `diagnosing-bugs`
- `to-issues`
- `codebase-design`
- `improve-codebase-architecture`
- `ponytail` from `DietrichGebert/ponytail`

`ponytail` is the shortest-path and LOC-reduction skill. `AGENTS.md` tells Codex to follow `.codex/skills/ponytail/SKILL.md`.

## Apply

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/klaach_harness/main/apply.sh)
```

This harness intentionally does not install Claude Code files or portable prompts.

## Finish Gate

Use `tools/preflight-harness.sh` while work is in progress.

Use `tools/finish-harness.sh` only when work is ready to hand off. It reruns preflight and fails unless `git status --short --untracked-files=all` is clean.
