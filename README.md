# Pit-Stop

*Drive in, get fixed, come out faster. You stay in the car.*

[中文](README.zh-CN.md) | English

Pit-stop is a cross-runtime agent skill: **one instruction runs a full project improvement
loop — read → find → fix → verify → report — with no mid-run questions.**

```
Use pit-stop on <project path>
```

The agent loads context, finds weaknesses (every one with `path:line` evidence),
fixes them in a review→fix loop, verifies with real tool output, and returns once
with a report split into verified / unverified / remaining. Push and publish
never happen without your explicit word.

## Install (30 seconds)

```bash
cp -r skills/pit-stop ~/.agents/skills/   # Claude Code, Codex, Hermes, OpenCode, Pi
```

Claude Code plugin, Codex plugin, OpenCode command, Cursor/Windsurf rules,
and a destructive-command hook are bundled — see the repo layout. Details per
harness in `docs/SPEC.md`.

## What makes it different

- **Closed loop, not a review.** Reviewers stop at findings; pit-stop fixes, re-reviews
  (max 3 rounds, cross-round ledger, escalation on stagnation), and only then reports.
- **Guardrails in three layers.** Banned list in prose, PreToolUse hook that blocks
  destructive commands mechanically, and a pre-push secrets sweep.
- **Evidence before claims.** No verification run in the turn = no success claim.
  Reports carry tool outputs, not adjectives.
- **Cheap to run, honest about cost.** Phases report spend; one phase past $20 stops itself.

## Repo layout

```
skills/pit-stop/SKILL.md          # the skill (<500-word core)
skills/pit-stop/references/       # phases, guardrails, verification
skills/pit-stop/templates/        # report template
hooks/block-destructive.sh        # L2 guardrail (Claude-family hooks)
commands/ .opencode/              # slash-command entries
.claude-plugin/ .codex-plugin/ .hermes-plugin/ .cursor/ .windsurf/
examples/before-after.md          # real run, real diff
docs/SPEC.md                      # full specification (v3)
```

MIT. Built by studying superpowers, mattpocock/skills, ponytail, Trail of Bits
skills, BugHunter, and code-review-graph — standing on their shoulders, see `docs/SPEC.md`.
