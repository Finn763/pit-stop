# Phases (detail for SKILL.md)

## 1. Load

- Read: README + AGENTS.md/CLAUDE.md (or equivalent) + `git status --short` + `git log --oneline -20`.
- Output first line of work: `MODE: <what counts as a finding> / <what is rejected>`.
- Missing key fact (target? forbidden zones? prod vs dev?): ask ONCE. No answer → strictest
  defaults (read-only diagnosis + report, no writes beyond scratch files).

## 2. Find

- Order: user-named target → git hot spots (files recurring in recent commits) → full tree.
- Rules: `path:line` evidence per finding; recorded decisions/known-pit lists are not
  re-litigated unless current friction justifies reopening (mark it: "reopening because…").
- Tags: `delete` dead/speculative · `stdlib` hand-rolled stdlib · `native` platform already does it ·
  `yagni` one-use abstraction · `shrink` same logic fewer lines · `perf` hot path/complexity/repeated
  work — Strong needs a measured baseline (before/after timing or profiler output); no measurement
  = Speculative, report only · `security` trust-boundary hole · `obs` blind spot (no test/log/metric
  where one is owed).
- Strength: `Strong` (fix now) / `Worth exploring` (fix if cheap) / `Speculative` (report only).
- Empty: `Lean already. Ship.`

## 3. Propose

- Strong items → symptom + evidence + impact + minimal fix + cost. No "could be improved"
  without exactly what to change and why.
- NOT-doing list with trigger conditions ("add when…").

## 4. Fix

- Fix → independent review → fix… until clean or `--max-rounds` (default 3).
- Findings ledger across rounds; never fix the same item twice without new information.
- Reviewer/fixer separation: a fix lane's own eyes read its output as clean; fresh angle catches
  its own error class. Prefer a different model or explicit adversarial prompt for review.
- Stop conditions: tests red and unfixable in-round · forbidden-zone touch · phase spend > $20 ·
  two stagnant rounds. All → "needs human", keep moving to report.

## 5. Report

- Header: `Generated fully automatically by pit-stop`.
- Blocks: changed (diff stat) / verified (tool outputs, exit codes) / unverified /
  remaining incl. needs-human items.
- Every pasted log/diff/redacted evidence: secrets, tokens, PII, intranet paths removed.
