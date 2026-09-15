# Report (detail for SKILL.md)

- Header: `Generated fully automatically by pit-stop`.
- Blocks: changed (diff stat) / verified (tool outputs, exit codes) / unverified /
  remaining incl. needs-human items.
- Remaining: needs-human first; ≤3 `[idea]` candidates behind them (`ideas.md` contract).
  A needs-human item that came from an attempt carries `tried: <what you already ran>` inline, so
  the reader does not redo ruled-out work; a stop-type item (budget, forbidden zone, stagnation)
  carries `tried: none — stopped because …`.
- Remaining opens with one `Next:` line — the single action the human should take now
  (a command or a decision). It is a line, not an item: no `tried:` field. The reader must not
  scan to the bottom to find it, and it is not a claim: no evidence needed for a next step, but
  nothing else may appear there without tool output.
- Every pasted log/diff/redacted evidence: secrets, tokens, PII, intranet paths removed.
- Layout: `templates/report.md`.
