#!/usr/bin/env bash
# Doc/adapter consistency gate (CI). Pure bash + awk — no grep/jq, same
# constraint as the L2 guardrail, so it also runs on bare Windows shells.
# Catches the three drift classes this repo has actually hit:
#   1. an entry point that still enumerates five phases (or misses Ideas)
#   2. the [idea] format string drifting between its two homes
#   3. SKILL.md creeping past the 500-word core cap
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
stale=$(git ls-files | while IFS= read -r f; do
  case "$f" in
    docs/release-notes/*|CHANGELOG.md|examples/*|docs/architecture.*|hooks/check-consistency.sh) continue ;;
    *.png|*.jpg|*.ico|*.svg) continue ;;
  esac
  [ -f "$f" ] || continue
  awk '
    { line = tolower($0) }
    index(line, "five phases") ||
    index($0, "五阶段") ||
    index($0, "load → find → propose → fix → report") ||
    index($0, "load, find, propose, fix, report") ||
    index($0, "装载→找缺点→给建议→改→汇报") { print FILENAME; exit }
  ' "$f"
done)
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

if [ "$fail" -eq 0 ]; then
  echo "consistency: PASS"
  exit 0
fi
echo "consistency: FAIL ($fail)"
exit 1
