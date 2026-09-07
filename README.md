<div align="center">

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.png">
    <img src="assets/logo.png" width="200" alt="Pit-stop logo">
  </picture>
</p>

# Pit-Stop

*Drive in, get fixed, come out faster. You stay in the car.*

[![License: MIT](https://img.shields.io/badge/License-MIT-3fb950?style=flat-square&labelColor=black)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/Finn763/pit-stop?style=flat-square&logo=github&labelColor=black)](https://github.com/Finn763/pit-stop/stargazers)
[![Skills](https://img.shields.io/badge/skills-1-8957e5?style=flat-square&labelColor=black)]

[中文](README.zh-CN.md) | English

</div>

> Review agents stop at findings. Pit-stop finishes the job.

Pit-stop is a cross-runtime agent skill: **one instruction runs a full improvement
loop — read → find → fix → verify → report — with no mid-run questions.**

```
Use pit-stop on <project path>
```

You say one line. The agent loads context, finds weaknesses (every one with
`path:line` evidence), fixes them in a review→fix loop, verifies with real tool
output, and returns once with a report split into verified / unverified /
remaining. Push and publish never happen without your explicit word.

---

## Why pit-stop exists

Built to fix three failure modes every agent owner has met:

- **#1: The agent reports, never fixes.** Reviews end with "you should…", and the
  diff never happens. **Fix:** the loop doesn't end at findings — fix, re-review
  (max 3 rounds, cross-round ledger, escalation on stagnation), then report.
- **#2: "Done" with no proof.** "Fixed!", "tests pass!" — with no command output
  behind the words. **Fix:** evidence before claims. No verification run in the
  turn = no success claim. Reports carry tool outputs, not adjectives.
- **#3: Improvement means bloat.** Suggestions pile on abstractions nobody asked for.
  **Fix:** every finding is tagged (`delete/stdlib/native/yagni/shrink/perf/security/obs`),
  Speculative items are reported, never built. Nothing found: `Lean already. Ship.`

---

## How it runs

![pit-stop run loop](docs/architecture.svg)

Five phases, one pass, zero mid-run questions — guardrails on top, escalation exit below.
[▶ Interactive version](https://finn763.github.io/pit-stop/architecture.html)

---

## The guardrail

The L2 hook (`hooks/block-destructive.sh`) runs in Claude-family harnesses and fails closed — a command it can't parse is blocked. Feed it a destructive command and it exits 2 with the reason:

```
$ echo '{"tool_input":{"command":"rm -rf /"}}' | bash hooks/block-destructive.sh
BLOCKED by pit-stop: 'rm -rf /' matches file deletion (rm). Destructive ops need the human's explicit word.
$ echo $?
2
```

Safe commands pass through untouched (`grep`, `man rm`, `git commit -m "... rm ..."`).

---

## Install (30 seconds)

```bash
npx skills add Finn763/pit-stop
```

Pick your agent when asked; update later with `npx skills update`. Per harness:

| Harness | Install |
|---|---|
| Claude Code | `/plugin marketplace add Finn763/pit-stop`, then `/plugin install pit-stop@pit-stop` |
| Codex | plugin from `.codex-plugin` (see repo), or `npx skills` above |
| Cursor | rule from `.cursor/rules/` (auto-loaded); `.cursor-plugin/` for Cursor Plugins |
| Gemini CLI | `gemini extensions install https://github.com/Finn763/pit-stop` |
| Pi | pi-package via `package.json`, or copy `skills/` |
| OpenCode | command from `.opencode/command/`, or copy `skills/` |
| Hermes | plugin from `.hermes-plugin`, or copy `skills/` |
| Anything else | `cp -r skills/pit-stop ~/.agents/skills/` |

No per-repo setup — there is nothing to configure.

---

## What pit-stop pins down

| Area | What's pinned down |
|---|---|
| Run | Five phases, one pass: load → find → fix → verify → report. Zero mid-run questions |
| Findings | Every one with `path:line` evidence, a tag, and a strength — Speculative items are reported, never built |
| Fix loop | Review→fix with an independent reviewer, max 3 rounds, cross-round ledger, stagnation escalates to human |
| Verification | No verification run in the turn = no success claim. Reports carry tool output, not adjectives |
| Cost | Phases report spend; one phase past $20 stops itself |
| Push / publish | Never automatic. Everything waits in the workdir for one explicit word |

---

<details>
<summary><strong>Repo layout</strong></summary>

```
skills/pit-stop/SKILL.md          # the skill (<500-word core)
skills/pit-stop/references/       # phases, guardrails, verification
skills/pit-stop/templates/        # report template
hooks/block-destructive.sh        # L2 guardrail (Claude-family hooks)
commands/ .opencode/              # slash-command entries
.claude-plugin/ .codex-plugin/ .cursor-plugin/ .devin-plugin/
.kimi-plugin/ .hermes-plugin/ .pi/ .cursor/ .windsurf/  # per-harness adapters
gemini-extension.json  GEMINI.md  package.json
examples/before-after.md          # real run, real diff
docs/SPEC.md                      # full specification (v3)
```

</details>

MIT. Built by studying superpowers, mattpocock/skills, ponytail, Trail of Bits
skills, BugHunter, and code-review-graph — standing on their shoulders, see `docs/SPEC.md`.
