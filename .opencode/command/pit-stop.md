---
description: Run a full pit-stop on a project
---

Run the pit-stop skill on `$ARGUMENTS` (project path; optional `--禁区` forbidden
zones; optional `--max-rounds N`). Six phases in order — load, find, propose, fix,
ideas, report — under the skill's guardrails. Findings carry `path:line` evidence,
a tag (`delete/stdlib/native/yagni/shrink/perf/security/obs`), and a strength
(`Strong/Worth exploring/Speculative`); round state lives in `.pit-stop/run.md`.
Push/commit never automatic.
