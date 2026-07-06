# PROFILES.md - Optional Codex MCP Profiles

The base harness keeps optional stack integrations project-local.

## Profiles

| Profile | MCP | Auth |
| --- | --- | --- |
| Vercel | `https://mcp.vercel.com` | Hosted OAuth in the client |
| Supabase | `https://mcp.supabase.com/mcp?read_only=true` | Hosted OAuth; set `SUPABASE_PROJECT_REF` to pin a project |
| Stripe | `npx -y @stripe/mcp@latest` | `STRIPE_SECRET_KEY` forwarded from the environment |

Figma is intentionally excluded.

## Commands

```bash
tools/apply-profile.sh vercel
tools/apply-profile.sh supabase
tools/apply-profile.sh stripe
tools/apply-profile.sh all --dry-run

tools/remove-profile.sh stripe
tools/check-profile.sh all
tools/audit-capabilities.sh --expect-profile all
```

## Skill Policy

Base skills are Codex-only and live under `.codex/skills/`:

- `find-skills`
- `superpowers`
- Matt Pocock workflow skills
- `ponytail`

Do not add Claude mirrors, portable prompts, broad UI-design bundles, or extra stack skills to the base harness. Use `find-skills` for project-specific additions.
