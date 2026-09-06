# Before / after: pit-stop vs hand-rolled flow (real run, 2026-09-04)

Target: an event-probability prediction engine (Python + TS, DuckDB, Windows schtasks).
The pit-stop flow below is what this skill now encodes; it ran via two Claude Code
agents in ~40 minutes of wall time.

## Before (hand-rolled, human-orchestrated)

- Human dispatches research agent with a bespoke prompt, waits, re-dispatches on
  budget blowout ($5 cap hit with zero output), splits stalled work by hand.
- Findings reviewed by human line by line; fixes dispatched per item; verification
  re-run by human (`replay --limit 3` → Brier JSON).
- Push gated by human-run secrets sweep. Total human touches: ~15.

## After (pit-stop encoded)

Same run expressed as one instruction: `pit-stop <repo>`. The skill prescribes:

- MODE line first, hot-spot scoping, `path:line` evidence per finding, strength badges
  (Speculative = report only — kills the padding the hand-rolled run produced).
- Fix→review loop, max 3 rounds, findings ledger (the hand-rolled run fixed, re-broke,
  and re-fixed the same npm description; the ledger prevents exactly that).
- Verification gate per claim; report split verified/unverified/remaining.
- Push waits for one explicit word; secrets sweep is mechanical, not remembered.

## Measured deltas (this run)

- Findings with file:line evidence: 8/8 (hand-rolled first draft: 5/8, rest "trust me").
- Verbal-only success claims intercepted: 2 ("dispatched", "pushed" — both demanded
  tool receipts under the new rule).
- Cost of one full loop on this repo: within a single-digit $ budget on Sonnet-class models.

Honest baseline note: n=1 repo, orchestrated run. Independent re-runs welcome —
that is what `docs/SPEC.md` §6 is for.
