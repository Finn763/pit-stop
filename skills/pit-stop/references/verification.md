# Verification (detail for SKILL.md)

## The gate

```
BEFORE claiming any status:
1. IDENTIFY: what command proves this claim?
2. RUN: execute the FULL command, fresh, complete
3. READ: full output, exit code, failure count
4. VERIFY: does the output confirm the claim? NO → state actual status with evidence
5. ONLY THEN: make the claim
```

Skip any step = lying, not verifying.

A `Tests pass` / `Linter clean` claim whose own diff introduces a check-skipping marker
(`guardrails.md` L3b) is void until that marker carries a stated reason or is gone.

## Claim table

| Claim | Requires | Not sufficient |
|---|---|---|
| Tests pass | the project's own test runner over the suite that repo defines — never a single test file: N>0 tests ran, 0 failures | earlier run, "should pass", `0 failures` with no tests collected, one green test file standing in for a suite nobody ran |
| Linter clean | linter output: 0 errors, files actually linted | partial check, extrapolation, a linter that matched no files |
| Build succeeds | build exit 0 | linter green, logs look fine |
| Bug fixed | original symptom reproduced fixed | code changed, assumed fixed |
| Perf improved | before/after measurement (timing/profiler delta) | code changed, "feels faster" |
| Agent completed | VCS diff shows the changes | agent reports "success" |
| Requirements met | line-by-line checklist | tests passing |

A suite run that ends red has not verified the claim: name every failing test in the report,
including the ones this run did not cause (`report.md` — the report may not soften a failed
verification). A failure watched scrolling past and left unnamed voids the claim it sits beside.

## Red flags — stop

"should / probably / seems" · satisfaction before verification ("Done!") · commit/push/PR
without verification · trusting agent self-reports · partial verification · "just this once" ·
tired and wanting it over · ANY success wording without a verification run behind it.

## Unverified is a state, not a verdict

An item this run could not settle is never written as a result: no badge, no "likely confirmed",
no number standing in for a fact nobody checked. Write the missing fact and the smallest command
that settles it, so the reader runs one thing. It is also not where a `Speculative` finding parks
— that one keeps its tag and badge in the findings list.
