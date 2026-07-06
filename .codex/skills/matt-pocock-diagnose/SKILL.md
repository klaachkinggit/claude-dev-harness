---
name: matt-pocock-diagnose
description: Use for debugging failures where root cause must be confirmed before changing production code.
---

# Diagnose

Follow this sequence without skipping or reordering steps.

1. Reproduce: get a reliable reproduction and confirm the bug exists now.
2. Minimize: find the smallest input or state that triggers it.
3. Hypothesize: list three possible causes ranked by likelihood.
4. Instrument: add targeted logging or assertions to test the top hypothesis.
5. Confirm root cause: verify the hypothesis before touching production code.
6. Fix: make the minimal change.
7. Test: add a regression test that would have caught it.
8. Clean up: remove debug instrumentation.

Report findings at each step before moving to the next.
