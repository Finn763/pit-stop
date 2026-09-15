# Fix (detail for SKILL.md)

- Findings ledger across rounds; never fix the same item twice without new information.
- Attempts ledger too: a failed approach (reverted) is recorded and not re-run. Record the
  approach's own failure only — a tool or environment failure is logged separately and does not
  blacklist the approach.
- Before a behavior-preserving fix (`delete`/`shrink`/`stdlib`/`native`/`yagni`), answer four:
  same output for every input? same error behavior? same side effects and ordering? existing
  tests pass unmodified? Any no → it's a behavior change, not cleanup — re-scope or stop.
  Bug/security/perf fixes exempt: the behavior change IS the fix.
- What did this change orphan? Imports, variables or functions it left unused are removed in the
  same change. This is an obligation, not a fifth gate: answer it once the four above hold. Only
  what this change orphaned — unrelated dead code stays.
