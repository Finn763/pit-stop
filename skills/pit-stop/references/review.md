# Review (detail for SKILL.md)

- Fix → independent review → fix… until clean or `--max-rounds` (default 3).
- Reviewer/fixer separation: a fix lane's own eyes read its output as clean; fresh angle catches
  its own error class. Prefer a different model or explicit adversarial prompt for review.
- Stop conditions: tests red and unfixable in-round · forbidden-zone touch · phase spend > $20 ·
  two stagnant rounds. All → "needs human", keep moving to Ideas.
- Two-axis recheck after a fix round: repo-style axis (does the diff follow the codebase's
  existing conventions?) and proposal axis (does it do what this round's proposal said?).
  Small diffs: self-check. Large: independent reviewer.
