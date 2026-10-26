# Fix (detail for SKILL.md)

- Findings ledger across rounds; never fix the same item twice without new information.
- Attempts ledger too: a failed approach (reverted) is recorded and not re-run. Record the
  approach's own failure only — a tool or environment failure is logged separately and does not
  blacklist the approach.
- Both ledgers live on disk, not in context (`templates/run.md` → `<target>/.pit-stop/run.md`).
  Context is lost to compaction; the round counter and the two ledgers are what a resumed run
  needs and the only thing it cannot rebuild from the diff.
  - Write the ledger before the first fix, then update `STATUS:` and append to the round and
    attempt lines as each round closes. Fixed shapes, one line per entry, `|`-separated fields.
  - Ship `<target>/.pit-stop/.gitignore` containing `*` when the directory is created, so the
    ledger never shows up in `git status --porcelain` and cannot enter the review range.
  - Fresh instruction: overwrite the ledger. It describes one run, and a stale one misleads.
  - Resume — after a compaction, or the user says continue/resume: read `STATUS:` first.
    `fix <N>` continues round N with the rounds already spent still counted against
    `--max-rounds`, and skips phases whose `STATUS:` marker they are past. Never re-fix an
    `open` finding whose `fixed` twin exists, and never retry a `revert` approach.
- Before a behavior-preserving fix (`delete`/`shrink`/`stdlib`/`native`/`yagni`), answer four:
  same output for every input? same error behavior? same side effects and ordering? existing
  tests pass unmodified? Any no → it's a behavior change, not cleanup — re-scope or stop.
  Bug/security/perf fixes exempt: the behavior change IS the fix.
- What did this change orphan? Imports, variables or functions it left unused are removed in the
  same change. This is an obligation, not a fifth gate: answer it once the four above hold. Only
  what this change orphaned — unrelated dead code stays.
