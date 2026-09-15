# Review (detail for SKILL.md)

- Fix → independent review → fix… until clean or `--max-rounds` (default 3).
- Reviewer/fixer separation: what must be independent is the review of the diff, not the process
  that produces it. Where the host has a subagent primitive, hand the fresh agent only the diff,
  this round's proposal and the standard — never the fix lane's reasoning. Where it does not,
  re-read the diff from that same starting point instead of recalling why you wrote it. Prefer a
  different model or an explicit adversarial prompt either way.
- Before flagging a regression, state the strongest case for the current code at that spot; if
  you cannot, you have not read it — report that item as `Worth exploring` at most, never as a
  regression. To overturn an existing finding, name the `path:line` whose text literally
  contradicts it; otherwise it stands.
- Stop conditions: tests red and unfixable in-round · forbidden-zone touch · phase spend > $20 ·
  two stagnant rounds. All → "needs human", keep moving to Ideas.
- Two-axis recheck after a fix round: repo-style axis (does the diff follow the codebase's
  existing conventions?) and proposal axis (does it do what this round's proposal said?).
  Orphan cleanup that `fix.md` obliges is in scope by definition — never flag it as an
  out-of-proposal change. Small diffs: the review is a self-check of the diff; large diffs:
  hand it to a fresh agent where the host has one.
