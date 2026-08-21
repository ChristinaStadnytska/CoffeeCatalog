---
description: Generate a structured PR description from the current git diff
---

You are generating a pull request description for the CoffeeCatalog repo.

Steps:

1. Run `git diff main...HEAD` (or `git diff --staged` if nothing is committed
   to the branch yet) to see the actual changes.
2. Run `git log main..HEAD --oneline` to see the commit history for this
   branch.
3. Summarize the change using exactly this template:

## What changed
(2-4 sentences, plain language — no code dump, no file-by-file listing)

## Why
(the problem this solves — reference the bug/task number if one exists)

## How it was tested
(manual steps actually taken, and/or which unit tests were added or updated
— be explicit about what is NOT covered rather than implying full coverage)

## Risk / rollback
(what could realistically break, and how to revert if it does)

Rules:

- Never invent testing that wasn't actually done. If something wasn't
  tested, say so plainly under "How it was tested" instead of omitting it.
- Keep "What changed" free of implementation detail — the diff already shows
  that; this section is for a reviewer skimming on their phone.
- If the diff touches `NetworkService` or `CoffeeListViewModel`, explicitly
  state whether the corresponding `MockNetworkService`-based tests were
  updated to match.
