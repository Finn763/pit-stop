#!/bin/bash
# pit-stop L2 guardrail — test matrix.
# Runs every case through hooks/block-destructive.sh exactly as Claude Code
# calls it: JSON on stdin; exit 2 = blocked, exit 0 = allowed.
# Two modes per case:
#   jq     — extraction via jq (skipped when jq is not installed)
#   no-jq  — POSIX awk fallback (PATH staged: jq removed, cat+awk staged in)
# Exit 0 = every runnable expectation met; 1 = any mismatch.
# CI runs this on ubuntu/macos/windows: .github/workflows/ci.yml
set -u
HOOK="$(cd "$(dirname "$0")" && pwd)/block-destructive.sh"
# Absolute path: `PATH=x bash` would look up bash itself on the new PATH.
BASH_BIN="$(command -v bash)"
fail=0
run=0

stage_bin() { # temp dir with wrapper scripts for cat+awk only (jq deliberately absent)
  local d t p chmod_cmd
  d=$(mktemp -d) || { echo "mktemp failed" >&2; exit 1; }
  chmod_cmd=$(command -v chmod || printf '%s' /usr/bin/chmod)
  for t in cat awk; do
    p=$(command -v "$t") || { echo "tool '$t' not found" >&2; exit 1; }
    printf '#!/bin/sh\nexec '\''%s'\'' "$@"\n' "$p" > "$d/$t" || { echo "cannot stage $t" >&2; exit 1; }
    "$chmod_cmd" +x "$d/$t" 2>/dev/null
  done
  printf '%s' "$d"
}
STAGED="$(stage_bin)"

json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

# expect<TAB>command — block = hook must exit 2, pass = must exit 0.
# The three "pass (residual)" cases are by design: pattern matching is a
# tripwire, not a sandbox — these stay L1/L3 territory (see references/guardrails.md).
cases() { cat <<'EOF'
block	rm -rf /
block	sudo rm -rf x
block	sudo -n rm -rf x
block	command rm x
block	do rm x
block	echo a && rm -rf x
block	echo a; rm -rf x
block	echo a | rm x
block	\rm -rf x
block	env rm -rf x
block	nohup rm -rf x
block	time rm -rf x
block	ls | xargs rm
block	find . -exec rm -rf {} +
block	find . -execdir rm -rf {} +
block	find . -name "*.tmp" -delete
block	echo "a" && rm -rf /tmp/x
block	git push origin main
block	git push
block	git push --force
block	sudo git push
block	git reset --hard HEAD
block	git reset -q --hard HEAD
block	git clean -fd
block	git clean -fdx
block	git branch -D feat
block	git checkout .
block	git checkout -- .
block	git restore .
block	git rm file.txt
block	git rm -r --cached x
block	echo ok && git push
block	hg push --force
block	:(){ :|:& };:
pass	grep foo README.md
pass	man rm
pass	git commit -m "fix rm logic"
pass	git commit -m "learn git push"
pass	grep "git push" README.md
pass	git commit -m "drop git reset --hard from docs"
pass	git checkout ./src/x.ts
pass	git status
pass	git config --global push.autoSetupRemote true
pass	echo hello
pass	printf "rm -rf /"
pass	echo "git push"
pass	find . -name "*.tmp" -print
pass	git remote -v
pass	mkdir -p /tmp/x && ls
pass	sh -c 'rm -rf /'
pass	env FOO=1 rm x
pass	git -C repo push
pass	python -c "os.remove('f')"
block	rm -rf /tmp/x; echo '{"command":"y"}'
pass	echo '{"command":"y"}' && git status
EOF
}

# Full hook-input payloads (not just the command): exercise the tool_input
# object scan — other keys, braces inside string values, embedded JSON
# templates in the command itself.
rawcases() { cat <<'EOF'
block	{"tool_input":{"description":"has } brace","command":"rm -rf /"}}
pass	{"tool_input":{"description":"has } brace","command":"git status"}}
block	{"tool_input":{"command":"rm -rf /tmp/x; echo '{\"command\":\"y\"}'"}}
block	{"session_id":"a","transcript_path":"t","cwd":"D:/x","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m \"fix\" && rm -rf /tmp/x"}}
pass	{"session_id":"a","transcript_path":"t","cwd":"D:/x","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m \"fix rm logic\" && git status"}}
EOF
}

run_case() { # expect cmd mode
  local expect="$1" cmd="$2" mode="$3" payload ec verdict
  if [ "$mode" = jq ]; then
    payload=$(printf '%s' "$cmd" | jq -Rsc '{tool_input:{command:.}}')
  else
    payload="{\"tool_input\":{\"command\":\"$(json_escape "$cmd")\"}}"
  fi
  printf '%s\n' "$payload" | PATH="$STAGED" "$BASH_BIN" "$HOOK" >/dev/null 2>&1
  ec=$?
  run=$((run + 1))
  if { [ "$expect" = block ] && [ "$ec" -eq 2 ]; } || { [ "$expect" = pass ] && [ "$ec" -eq 0 ]; }; then
    return 0
  fi
  fail=$((fail + 1))
  printf 'FAIL  [%s] expected %s, got exit %s: %s\n' "$mode" "$expect" "$ec" "$cmd"
  return 1
}

run_raw_case() { # expect payload mode — payload is the full hook stdin JSON
  local expect="$1" payload="$2" mode="$3" ec
  printf '%s\n' "$payload" | PATH="$STAGED" "$BASH_BIN" "$HOOK" >/dev/null 2>&1
  ec=$?
  run=$((run + 1))
  if { [ "$expect" = block ] && [ "$ec" -eq 2 ]; } || { [ "$expect" = pass ] && [ "$ec" -eq 0 ]; }; then
    return 0
  fi
  fail=$((fail + 1))
  printf 'FAIL  [%s] expected %s, got exit %s: %s\n' "$mode" "$expect" "$ec" "$payload"
  return 1
}

for mode in jq no-jq; do
  echo "=== mode: $mode ==="
  if [ "$mode" = jq ] && ! command -v jq >/dev/null 2>&1; then
    echo "  skipped: jq not installed on this machine"
    continue
  fi
  while IFS=$'\t' read -r expect cmd; do
    [ -n "$expect" ] && run_case "$expect" "$cmd" "$mode"
  done < <(cases)
  while IFS=$'\t' read -r expect payload; do
    [ -n "$expect" ] && run_raw_case "$expect" "$payload" "$mode"
  done < <(rawcases)
done

echo
echo "cases run: $run, failures: $fail"
[ "$fail" -eq 0 ]
