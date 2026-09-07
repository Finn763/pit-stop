#!/bin/bash
# pit-stop L2 guardrail: PreToolUse hook blocking destructive git/shell commands.
# Install (Claude Code): project `.claude/settings.json` or global `~/.claude/settings.json`,
# matcher Bash, command = path to this file. Blocked tool exits 2 with a refusal note.
# Pure bash + awk (POSIX, no jq/grep dependency). Fails closed: a command that
# cannot be extracted is blocked rather than silently passed.
# Test matrix (60 cases x 2 extraction modes): hooks/test-block-destructive.sh
INPUT=$(cat)

# extract .tool_input.command, decoding JSON string escapes (\" and \\).
# jq when available; otherwise POSIX awk. \u escapes and dangling escapes are
# not decodable here -> fail closed.
CMD=""
if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  CMD=$(printf '%s' "$INPUT" | awk '
  { buf = buf $0 }
  END {
    n = length(buf)
    # locate the unescaped "tool_input" key followed by ":"
    ti = 0
    for (i = 1; i <= n - 11; i++) {
      if (substr(buf, i, 12) != "\"tool_input\"") continue
      if (i > 1 && substr(buf, i - 1, 1) == "\\") continue
      j = i + 12
      while (j <= n && substr(buf, j, 1) ~ /[[:space:]]/) j++
      if (substr(buf, j, 1) == ":") { ti = j; break }
    }
    if (!ti) exit
    j = ti + 1
    while (j <= n && substr(buf, j, 1) ~ /[[:space:]]/) j++
    if (substr(buf, j, 1) != "{") exit
    # scan the tool_input object: brace depth + in-string + escape aware
    depth = 1; instr = 0; esc = 0; s = 0
    for (i = j + 1; i <= n; i++) {
      c = substr(buf, i, 1)
      if (esc) { esc = 0; continue }
      if (c == "\\") { esc = 1; continue }
      if (instr) { if (c == "\"") instr = 0; continue }
      if (c == "\"") {
        if (depth == 1 && substr(buf, i, 9) == "\"command\"") {
          k = i + 9
          while (k <= n && substr(buf, k, 1) ~ /[[:space:]]/) k++
          if (substr(buf, k, 1) == ":") { s = k + 1; break }
        }
        instr = 1
        continue
      }
      if (c == "{") depth++
      else if (c == "}") { depth--; if (depth == 0) break }
    }
    if (!s) exit
    i = s
    while (i <= n && substr(buf, i, 1) ~ /[[:space:]]/) i++
    if (substr(buf, i, 1) != "\"") exit
    # decode the string value: \" and \\ only; \u / dangling escape -> fail closed
    rest = substr(buf, i + 1)
    out = ""; esc = 0
    for (k = 1; k <= length(rest); k++) {
      c = substr(rest, k, 1)
      if (esc) {
        if (c == "u") { print ""; exit 2 }
        if (c == "\"") out = out "\""
        else if (c == "\\") out = out "\\"
        else out = out "\\" c
        esc = 0
      } else if (c == "\\") esc = 1
      else if (c == "\"") break
      else out = out c
    }
    if (esc) { print ""; exit 2 }
    print out
  }')
fi
if [ -z "$CMD" ]; then
  echo "BLOCKED by pit-stop: could not extract the command to check (jq missing or unparseable input)." >&2
  exit 2
fi

BLOCKED=""
case "$CMD" in
  *" -delete"*|*":(){ :|:& };:"*|*"push --force"*)
    BLOCKED="destructive command" ;;
  *"-exec rm "*|*"-execdir rm "*) BLOCKED="file deletion (find -exec rm)" ;;
esac

# rm in command position: start of command or after &&/;/|/(, with an optional
# prefix (sudo [flags] / do / command / env / nohup / time / xargs [flags]) and
# an optional leading backslash. Mentions in arguments (grep rm, man rm, commit
# messages, quoted strings) pass.
RM_PREFIX='(sudo([[:space:]]+-[^ ]+)*|do|command|env([[:space:]]+-[^ ]+)*|nohup([[:space:]]+-[^ ]+)*|xargs([[:space:]]+-[^ ]+)*|time)'
RM_RE="(^|[;&|(])([[:space:]]*${RM_PREFIX})?[[:space:]]*[\\]?rm([[:space:]]|$)"
if [[ "$CMD" =~ $RM_RE ]]; then
  BLOCKED="file deletion (rm)"
fi

# destructive git subcommands in command position only — a mention in a message
# or an argument (grep "git push", commit messages) does not trigger.
GIT_PREFIX='(sudo([[:space:]]+-[^ ]+)*|do|command)'
GIT_SUBS='(push|reset([[:space:]]+-[^ ]+)*[[:space:]]+--hard|clean[[:space:]]+-f[dx]*|branch([[:space:]]+-[^ ]+)*[[:space:]]+-D|checkout([[:space:]]+-[^ ]+)*[[:space:]]+\.|restore([[:space:]]+-[^ ]+)*[[:space:]]+\.|rm)'
GIT_RE="(^|[;&|(])[[:space:]]*${GIT_PREFIX}?[[:space:]]*git([[:space:]]+-[^ ]+)*[[:space:]]+${GIT_SUBS}([[:space:]]|$)"
if [[ "$CMD" =~ $GIT_RE ]]; then
  BLOCKED="destructive git command"
fi

if [ -n "$BLOCKED" ]; then
  echo "BLOCKED by pit-stop: '$CMD' matches $BLOCKED. Destructive ops need the human's explicit word." >&2
  exit 2
fi
exit 0
