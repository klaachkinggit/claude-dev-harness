# Adopt Harness — bring an existing project under this harness + clean up

Use when applying this harness to a project that was built **without** it and may
already carry its own skills, commands, hooks, or rules. Goal: adopt one shared
project harness with Codex and Claude provider mirrors, remove dead weight, keep
what's genuinely project-specific.

## Steps
1. **Inventory** what's already there — list it before touching anything:
   - `AGENTS.md`, `CLAUDE.md`, `prompts/`, `.mcp.json`
   - provider mirrors: `.codex/`, `.claude/`
   - legacy provider folders/files only if present (`.agents/`, `.cursor/`, `.cursorrules`, `GEMINI.md`, …)
   - git hooks (`git config --get core.hooksPath`), CI workflows in `.github/`
2. **Apply the harness** — run apply.sh for the tool(s) in use. It backs up any
   file it overwrites to `<file>.bak`.
3. **Audit each pre-existing skill / command** and classify:
   - **KEEP** — project-specific, useful, no harness equivalent.
   - **REDUNDANT** — duplicates a harness skill/prompt (e.g. a custom "debugger"
     vs `diagnose`, custom "commit gate" vs the git hooks). → remove.
   - **STALE / UNUSED** — unreferenced, outdated, or low quality. → remove.
   - **IMPROVABLE** — good idea, weak execution (200 lines of prose, vague
     description, no validators). → rewrite tighter: sharp description, add
     hard-stops/validators/scripts, cut prose.
4. **Propose the plan to the user BEFORE changing anything.** Show the
   keep / remove / merge / improve list. Removing skills is destructive — get
   explicit confirmation unless the user already requested the cleanup.
5. **On approval** — execute the plan. Reconcile rules: fold any project-specific
   rules into the bottom of `AGENTS.md` and mirror the same contract into
   `CLAUDE.md`. Never silently drop project rules.
6. **Verify** — `git config --get core.hooksPath` = `.githooks`; total skill
   count under ~10 per provider mirror; `.codex/skills` and `.claude/skills`
   are in sync when both runtimes are used; no in-repo harness archive folders;
   quick sanity run.

## Guardrails (harness rules apply)
- Destructive actions need confirmation unless already requested in the task.
- Prefer git history over archive folders for removed harness files. Do not keep
  harness archives in the repository tree.
- Never discard project-specific rules — migrate them.
- Duplicated provider entrypoints are intentional compatibility, not stale
  redundancy. Keep them in sync.
- Fewer, sharper skills beat many overlapping ones.
