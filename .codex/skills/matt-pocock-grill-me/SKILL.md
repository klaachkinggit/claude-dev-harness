---
name: matt-pocock-grill-me
description: Use before large or ambiguous implementation work to interview requirements and uncover missing decisions before coding.
---

# Grill Me

Before writing code for the task, conduct a requirements interview.

Cover these categories:

1. Scope: what is in scope and explicitly out.
2. Edge cases: failure modes and empty, null, or invalid input behavior.
3. Dependencies: existing code touched and what could break.
4. Data flow: where data comes from, where it goes, and who mutates it.
5. Error handling: what must be handled and what can bubble up.
6. Testing: acceptance criteria and required tests.
7. Performance: latency, memory, or throughput constraints.
8. Security: auth checks, input validation, and data exposure risk.
9. Rollback: how to recover if production breaks.

Present all questions at once, grouped by category. Write no code until the answers are confirmed.
