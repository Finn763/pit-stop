# pit-stop run ledger

On disk because a compaction erases context. Write it as `<target>/.pit-stop/run.md` before
the first fix and append one line per round. Read the resume rules in `references/fix.md`.

STATUS: <find | fix <round> | ideas | report | needs-human>
MODE: <one line: what counts as a finding here, what is rejected outright>
BASELINE: <git rev-parse HEAD> @ <date> — the review range starts here
MAX_ROUNDS: <N, from --max-rounds or 3>

## Findings ledger

- LEDGER open | <path:line> | <tag> | <Strong|Worth> | <one-line symptom> | round <N>
- LEDGER fixed | <path:line> | <one line: what landed>
- LEDGER skip | <path:line> | <one-line reason it is not fixed>
- LEDGER speculative | <path:line> | <one line — report only, never fixed>

## Attempts ledger

- ATTEMPT revert | <approach> | failed because: <the approach's own failure> | round <N>
- ATTEMPT env | <tool or environment failure> | round <N>

## Rounds

- ROUND <N> | reviewer: <model / angle, or "same model, adversarial"> | verdict: <clean | N findings | stagnant> | next: <what round N+1 does, or stop>
