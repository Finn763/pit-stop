# Review (detail for SKILL.md)

- Fix → independent review → fix… until clean or `--max-rounds` (default 3).
- Reviewer/fixer separation: a fix lane's own eyes read its output as clean; fresh angle catches
  its own error class. Prefer a different model or explicit adversarial prompt for review.
- Stop conditions: tests red and unfixable in-round · forbidden-zone touch · phase spend > $20 ·
  two stagnant rounds. All → "needs human", keep moving to report.
