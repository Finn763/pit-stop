# Review (detail for SKILL.md)

- Fix → independent review → fix… until clean or `--max-rounds` (default 3).
- Fix the reviewed range before the first edit: record `git rev-parse HEAD` then, and review that
  ref against the working tree — never against a branch that moved underneath the run (`git diff
  main` shows main's newer files as deletions of yours). The run does not commit, so the range is
  that ref plus every path the run created that git does not track yet (`git status --porcelain`,
  `??` lines): a plain `git diff` hides new files, and a fix that adds one would be reviewed as
  if the file were not there. Nothing changed and nothing added = a setup error, not a clean
  round — fix the range before reviewing it.
- Reviewer/fixer separation: what must be independent is the review of the diff, not the process
  that produces it. Where the host has a subagent primitive, hand the fresh agent only the diff,
  this round's proposal and the standard — never the fix lane's reasoning. Where it does not,
  re-read the diff from that same starting point instead of recalling why you wrote it. Prefer a
  different model or an explicit adversarial prompt either way — and say which seat the reviewer
  got: a dispatch that names no model inherits the fix lane's, which is the same eyes twice, so
  the round's independence is stated, not assumed. The review is read-only on this checkout — no
  edit, `git add`, `git stash`, `git commit`, `git checkout`/`switch`, no moving HEAD: the run's
  work is uncommitted and only commit and push are gated anywhere else (L1), while a reviewer
  that mutates the tree destroys a round with no history behind it. The reviewer dispatches
  nothing — a reviewer spawning its own reviewer buys a second seat that answers nothing.
- Re-check the unverified / needs-human list too: close what the repo can already answer, and
  refuse an item that is really a `Speculative` finding wearing a needs-human label.
- Before flagging a regression, state the strongest case for the current code at that spot; if
  you cannot, you have not read it — report that item as `Worth exploring` at most, never as a
  regression. To overturn an existing finding, name the `path:line` whose text literally
  contradicts it; otherwise it stands.
- The reviewer returns a `Declined to judge` list — every behavior it set aside as outside this
  round's proposal, one line each with the reason — and the run rules on each line; nothing is
  dropped silently, and an empty list means it set nothing aside. Grade by effect, not by the
  proposal's silence: a finding's strength is what a reader of the target repo gets if it ships,
  not whether the proposal named the trigger. The proposal axis below still grades whether the
  fix did what the proposal said — never what the proposal left unnamed; orphan cleanup (`fix.md`)
  stays in scope, so a reviewer that declined it made an error the run corrects.
- Stop conditions: tests red and unfixable in-round · forbidden-zone touch · phase spend > $20 ·
  two stagnant rounds. All → "needs human", keep moving to Ideas.
- Two-axis recheck after a fix round: repo-style axis (does the diff follow the codebase's
  existing conventions?) and proposal axis (does it do what this round's proposal said?).
  Orphan cleanup that `fix.md` obliges is in scope by definition — never flag it as an
  out-of-proposal change. Small diffs: the review is a self-check of the diff; large diffs:
  hand it to a fresh agent where the host has one.
