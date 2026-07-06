---
name: matt-pocock-tdd
description: Use for non-trivial behavior changes where a failing test should drive implementation.
---

# TDD

Implement the feature using strict red, green, refactor cycles.

## Red

- Write the failing test first.
- Run it and confirm it fails for the right reason.
- Do not write implementation before seeing the failure.

## Green

- Write the minimum code required to pass.
- Avoid cleanup or abstractions in this step.
- Run the test and confirm it passes.

## Refactor

- Improve naming, remove duplication, and simplify with tests green.
- Do not add behavior while refactoring.
- Run tests after each meaningful change.
