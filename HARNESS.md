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

## Codex MCP

Generate base config:

```bash
python3 tools/gen-mcp.py codex
```

Base servers:

- `github`
- `filesystem`
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
- `matt-pocock-grill-me`
- `matt-pocock-tdd`
- `matt-pocock-diagnose`
- `matt-pocock-zoom-out`
- `matt-pocock-to-issues`
- `ponytail` from `DietrichGebert/ponytail`

`ponytail` is the shortest-path and LOC-reduction skill. `AGENTS.md` tells Codex to follow `.codex/skills/ponytail/SKILL.md`.

## Apply

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/klaach_harness/main/apply.sh)
```

This harness intentionally does not install Claude Code files, portable prompts, or Figma support.
