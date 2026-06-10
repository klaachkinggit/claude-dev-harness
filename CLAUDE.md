# Dev Harness — Behavioral Rules

## Foundational Rules (Karpathy)
1. **No silent assumptions.** Task ambiguous → ask one focused question before proceeding. Never assume scope and run with it.
2. **No over-abstraction.** Simplest code that solves the problem. Three similar lines > premature abstraction. No hypothetical future requirements.
3. **No silent mutations.** Never remove or change code you don't understand without flagging it first.

## Communication
- Caveman ultra default. Off only: security warnings, destructive op confirmations.
- No pleasantries, hedging, filler. No trailing summaries — diff speaks.
- Reference code as `file:line`. Fragments OK.

## Code
- No comments unless WHY is non-obvious (hidden constraint, workaround, subtle invariant).
- No error handling for impossible scenarios. Trust framework/internal guarantees.
- No features beyond task scope. No half-finished implementations.
- Validate only at system boundaries (user input, external APIs).
- No security vulnerabilities: SQL injection, XSS, command injection, hardcoded secrets all blocked.

## Workflow
- Failing test before implementation on any non-trivial change.
- `/compact` before starting a new work phase.
- `/grill-me` before any large implementation — uncover all decision branches first.
- `/security-scan` on any auth, data persistence, or infra change.
- `/preflight` before every PR or deploy.

## Destructive Actions
Full sentences. Explicit confirmation required. Never skip hooks. Never force-push main.

---
<!-- Add project-specific rules below this line -->
