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
| Tests pass | runner output: N>0 tests ran, 0 failures | earlier run, "should pass", `0 failures` with no tests collected |
| Linter clean | linter output: 0 errors, files actually linted | partial check, extrapolation, a linter that matched no files |
| Build succeeds | build exit 0 | linter green, logs look fine |
| Bug fixed | original symptom reproduced fixed | code changed, assumed fixed |
| Perf improved | before/after measurement (timing/profiler delta) | code changed, "feels faster" |
| Agent completed | VCS diff shows the changes | agent reports "success" |
| Requirements met | line-by-line checklist | tests passing |

## Red flags — stop

"should / probably / seems" · satisfaction before verification ("Done!") · commit/push/PR
without verification · trusting agent self-reports · partial verification · "just this once" ·
tired and wanting it over · ANY success wording without a verification run behind it.
