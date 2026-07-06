# Applying This Harness

Run from the target project root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/klaachkinggit/klaach_harness/main/apply.sh)
```

No curl:

```bash
gh repo clone klaachkinggit/klaach_harness /tmp/klaach_harness
HARNESS_RAW_BASE=file:///tmp/klaach_harness bash /tmp/klaach_harness/apply.sh
rm -rf /tmp/klaach_harness
```

Do not leave a `klaach_harness/` folder inside the project.

## What Gets Applied

| Component | Path |
| --- | --- |
| Rules | `AGENTS.md` |
| MCP config | `.codex/config.toml` |
| Runtime hook | `.codex/hooks.json`, `.codex/hooks/protect-env.sh` |
| Skills | `.codex/skills/` |
| Git hooks + CI | `.githooks/`, `.github/workflows/ci.yml` |
| Harness docs | `README.md`, `HARNESS.md`, `PROFILES.md`, `APPLY.md` |
| Memory | `MEMORY.md`, `LESSONS.md`, `docs/adr/0000-template.md` |

## Verify

```bash
git config --get core.hooksPath
tools/check-agent-context.sh
tools/check-profile.sh
tools/preflight-harness.sh
```

`core.hooksPath` should be `.githooks`.

Add project-specific rules below the marker at the bottom of `AGENTS.md`.
