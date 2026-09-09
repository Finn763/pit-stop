#!/usr/bin/env bash
# Doc/adapter consistency gate (CI). Pure bash + awk — no grep/jq, same
# constraint as the L2 guardrail, so it also runs on bare Windows shells.
# Catches the four drift classes this repo has actually hit:
#   1. an entry point that still enumerates five phases (or misses Ideas)
#   2. the [idea] format string drifting between its two homes
#   3. SKILL.md creeping past the 500-word core cap
#   4. the bare "sudo" token sneaking back into the skill bundle
#      (skills-guard-v2 scores it HIGH -> hub installs hit a caution block)
# Run: bash hooks/check-consistency.sh   (exit 0 = pass, 1 = drift)
set -u

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root" || exit 2

fail=0
ok()  { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=$((fail + 1)); }

# exact substring match via index(); no regex escaping needed
has() { awk -v n="$2" 'index($0, n) { found = 1 } END { exit found ? 0 : 1 }' "$1"; }

echo "=== 1. six-phase flow in every entry point ==="
while IFS='|' read -r file needle; do
  [ -n "$file" ] || continue
  if [ ! -f "$file" ]; then bad "$file is missing"; continue; fi
  if has "$file" "$needle"; then ok "$file <- $needle"; else bad "$file lacks: $needle"; fi
done <<'PAIRS'
skills/pit-stop/SKILL.md|load → find → propose → fix → ideas → report
GEMINI.md|ideas → report
.cursor/rules/pit-stop.mdc|ideas → report
.windsurf/rules/pit-stop.md|ideas → report
commands/pit-stop.toml|Six phases
.opencode/command/pit-stop.md|Six phases in order
README.md|Six phases
README.zh-CN.md|六阶段
docs/SPEC.md|## 3. 六阶段
PAIRS

echo "=== 2. no stale five-phase wording ==="
# NOTE: no case/$( ) here — bash 3.2 (macOS /bin/bash) mis-parses case patterns
# inside command substitutions, closing $( ) at the pattern's `)`.
stale=""
while IFS= read -r f; do
  [[ "$f" == docs/release-notes/* || "$f" == CHANGELOG.md || "$f" == examples/* || "$f" == docs/architecture.* || "$f" == hooks/check-consistency.sh ]] && continue
  [[ "$f" == *.png || "$f" == *.jpg || "$f" == *.ico || "$f" == *.svg ]] && continue
  [ -f "$f" ] || continue
  if awk '
    { line = tolower($0) }
    index(line, "five phases") ||
    index($0, "五阶段") ||
    index($0, "load → find → propose → fix → report") ||
    index($0, "load, find, propose, fix, report") ||
    index($0, "装载→找缺点→给建议→改→汇报") { found = 1; exit }
    END { exit found ? 0 : 1 }
  ' "$f"; then
    stale="$stale $f"
  fi
done < <(git ls-files)

if [ -n "$stale" ]; then
  bad "stale five-phase wording in:"
  printf '     %s\n' $stale
else
  ok "no stale wording (release notes / CHANGELOG / examples exempt as history)"
fi

echo "=== 3. [idea] format string identical in both homes ==="
fmt='[idea] <capability ≤20 words> — <path:line> — probe: <≤12 words>'
for f in skills/pit-stop/references/ideas.md skills/pit-stop/templates/report.md; do
  if has "$f" "$fmt"; then ok "$f"; else bad "$f: [idea] format drift"; fi
done

echo "=== 4. SKILL.md word cap ==="
words=$(awk '{ n += NF } END { print n + 0 }' skills/pit-stop/SKILL.md)
if [ "$words" -lt 500 ]; then ok "SKILL.md $words words (<500)"; else bad "SKILL.md $words words (>=500)"; fi

echo "=== 5. no bare sudo token in the skill bundle ==="
# Hermes hub scans skills/pit-stop/ with skills-guard-v2: a bare "sudo" scores HIGH
# (sudo_usage) -> caution verdict -> hub installs hit a block. Critical-tier literals
# cannot be listed here (the literal itself would trip the scanner) — keep them out by
# review. Tracked files only: the hub fetches the committed tree.
# The guardrail docs describe the prefix class instead; the exact list is the RM_PREFIX
# regex in hooks/block-destructive.sh, with cases in hooks/test-block-destructive.sh.
# v0.3.0 regressed this once already.
scanhit=""
scanerr=0
while IFS= read -r f; do
  [[ "$f" == skills/pit-stop/* ]] || continue
  [ -f "$f" ] || continue
  awk '{ n = split(tolower($0), w, "[^a-z0-9]+"); for (i = 1; i <= n; i++) if (w[i] == "sudo") { found = 1; exit } } END { exit found ? 0 : 1 }' "$f"
  rc=$?
  if [ "$rc" -eq 0 ]; then
    scanhit="$scanhit $f"
  elif [ "$rc" -ne 1 ]; then
    bad "check 5: awk failed on $f (exit $rc)"
    scanerr=1
  fi
done < <(git ls-files)
if [ -n "$scanhit" ]; then
  bad "bare sudo token in:"
  printf '     %s\n' $scanhit
elif [ "$scanerr" -eq 0 ]; then
  ok "no bare sudo token in skills/pit-stop/"
fi

if [ "$fail" -eq 0 ]; then
  echo "consistency: PASS"
  exit 0
fi
echo "consistency: FAIL ($fail)"
exit 1
