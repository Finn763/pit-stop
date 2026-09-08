# Ideas — phase 5 (detail for SKILL.md)

Runs after the fix loop closes, before Report. Read-only: no edits, no new
files read, no subagent, no budget beyond the run's fuse.

## Admission — all four, else drop

- **Anchored**: the `path:line` appears in this run's findings/attempts ledger or diff.
- **Shaped**: one line — `[idea] <capability ≤20 words> — <path:line> — probe: <≤12 words>`.
- **Falsifiable**: the probe is the smallest command/check that would kill the idea.
- **Novel**: no existing find tag (delete/stdlib/native/yagni/shrink/perf/security/obs)
  can express it — if one can, it belongs to Find, not here.

## Kill list — any hit, drop it

- Missing `path:line`, or the anchor is not in this run's ledger/diff.
- "add tests / CI / logging / docs" — a missing test is `obs`, a Find finding, not an idea.
- Proposes a new dependency.
- Contradicts a fix made this run (e.g. re-adds what was just deleted as yagni).
- Duplicates a NOT-doing trigger already recorded.

## Budget and gate

- ≤3 lines, inside `## Remaining (needs human)`. Zero is the normal case.
- If the section exceeds 7 lines, drop ideas first — never drop a needs-human item.
- Never built in this run. The only path to code is the user saying go — that starts
  a new run with the idea as its named goal.
