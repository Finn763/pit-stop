# Guardrails (detail for SKILL.md)

Three layers. Documentation works everywhere; hooks where the host supports them;
a machine sweep at the end. Never rely on prose alone where enforcement exists.

## L1 — Banned (all hosts, no exceptions)

- Delete files (`rm`, `git clean -fd`, `git reset --hard`, `checkout .`).
- Read or write secrets/credentials (`.env`, keys, tokens, password stores).
- Touch CI publish chains, signing keys, release workflows.
- Write production databases or touch live data.
- Publish anything (npm/PyPI/Release/store) or `git push` — waits for one explicit user word.
- Rewriting history (`push --force`, rebase of shared branches).

## L2 — Hooks (Claude-family hosts; skip gracefully elsewhere)

Ship `hooks/block-destructive.sh` as PreToolUse on Bash (install snippet in README).
Blocks, at command position only — mentions in messages, arguments, and quoted
strings pass:
- `rm` with optional privilege-raising prefix (with `[flags]`) / `do` / `command` / `env` / `nohup` /
  `time` / `xargs [flags]`, optional leading `\`, at start or after `&&`/`;`/`|`/`(`.
- `find -exec rm` / `-execdir rm`, `find -delete`.
- git subcommands: `push`, `reset --hard`, `clean -f[dx]`, `branch -D`,
  `checkout .`, `restore .`, `git rm` (interleaved flags like `--`/`-q` tolerated),
  plus bare `push --force` and the fork bomb.
Extraction: jq when present; otherwise POSIX awk decoding `\"` and `\\`.
`\u` escapes or unparseable input → fail closed (exit 2) — a guardrail that
silently passes is no guardrail. Dependency: bash + awk only.
Documented residuals — pattern matching is a tripwire, not a sandbox; these stay
L1/L3 territory: `sh -c 'rm …'`, `python -c`, `env FOO=x rm`, `git -C <dir> push`,
redirection truncation. Test matrix: `hooks/test-block-destructive.sh`
(60 cases, jq/no-jq extraction modes, CI on three OS).
Blocked tool sees: "The user has prevented you from doing this." Exit 2.

## L3 — Pre-push sweep (machine)

Before any commit/push, scan the diff for `sk-|api_key=|gho_|sk-ant-|<intranet-IP>|<absolute
home paths>`. Zero hits or no push. Evidence-hygiene twin: reports and pasted logs carry
only what convinces — redact the rest by habit, verify by sweep.

## Step 0 — Scope truth

Before hunting defects, audit the promise: what the user asked for vs what is actually
built and reachable. "No bugs found" in something never built is the most dangerous
report. Unreachable code paths and uncompiled files are findings of the highest class.

## Claims audit

Every comment, docstring, test name, README line is a CLAIM about behavior. For each,
find the code path that must honor it. No honoring path = finding. A test that only
greps source text or seeds an untriggerable fixture proves decoration, not behavior.
