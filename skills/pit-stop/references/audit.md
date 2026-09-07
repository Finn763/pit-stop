# Audit — Load, Find, Propose (detail for SKILL.md)

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
- Security coverage (at least): XSS · injection (SQL/NoSQL/command) · SSRF · path traversal ·
  authZ/authN gaps (incl. missing tenancy checks) · secrets committed/hardcoded in source or
  logs (pattern-detect only, never extract values — .env-class files follow guardrails L1) ·
  unsafe deserialization · race conditions (check-then-act / TOCTOU). Call out exploitability
  AND impact.
- Strength: `Strong` (fix now) / `Worth exploring` (fix if cheap) / `Speculative` (report only).
- Empty: `Lean already. Ship.`

## 3. Propose

- Strong items → symptom + evidence + impact + minimal fix + cost. No "could be improved"
  without exactly what to change and why.
- NOT-doing list with trigger conditions ("add when…").
