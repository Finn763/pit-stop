# Fix (detail for SKILL.md)

- Findings ledger across rounds; never fix the same item twice without new information.
- Attempts ledger too: a failed approach (reverted) is recorded and not re-run. Record the
  approach's own failure only — a tool or environment failure is logged separately and does not
  blacklist the approach.
- Before a behavior-preserving fix (`delete`/`shrink`/`stdlib`/`native`/`yagni`), answer five:
  same output for every input? same error behavior? same side effects and ordering? existing
  tests pass unmodified? which imports, variables or functions did this change orphan — list
  them and remove them in the same change (only what this change orphaned; leave unrelated dead
  code alone). Any no → it's a behavior change, not cleanup — re-scope or stop.
  Bug/security/perf fixes exempt: the behavior change IS the fix.
