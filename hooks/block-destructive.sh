#!/bin/bash
# pit-stop L2 guardrail: PreToolUse hook blocking destructive git/shell commands.
# Install (Claude Code): project `.claude/settings.json` or global `~/.claude/settings.json`,
# matcher Bash, command = path to this file. Blocked tool exits 2 with a refusal note.
# Pure bash + awk (POSIX, no jq/grep dependency). Fails closed: a command that
# cannot be extracted is blocked rather than silently passed.
# Test matrix (90 cases x 2 extraction modes): hooks/test-block-destructive.sh
INPUT=$(cat)

# extract .tool_input.command, decoding JSON string escapes (\" and \\).
# jq when available; otherwise POSIX awk. \u escapes and dangling escapes are
# not decodable here -> fail closed.
CMD=""
if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
  # jq streams: a valid first value followed by garbage still prints, then exits
  # non-zero. Any parse error anywhere -> fail closed.
  [ $? -eq 0 ] || CMD=""
else
  CMD=$(printf '%s' "$INPUT" | awk '
  { buf = buf $0 }
  END {
    n = length(buf)
    # Structural check first: the jq path rejects any malformed JSON, so the
    # fallback must not accept a truncated or over-braced payload either.
    # String/escape aware brace balance, then a `}` tail (after trailing space).
    depth = 0; instr = 0; esc = 0
    for (i = 1; i <= n; i++) {
      c = substr(buf, i, 1)
      if (esc) { esc = 0; continue }
      if (instr) {
        if (c == "\\") esc = 1
        else if (c == "\"") instr = 0
        continue
      }
      if (c == "\"") { instr = 1; continue }
      if (c == "{") depth++
      else if (c == "}") { depth--; if (depth < 0) { print ""; exit 2 } }
    }
    m = n
    while (m > 0 && substr(buf, m, 1) ~ /[[:space:]]/) m--
    if (depth != 0 || instr || esc || substr(buf, m, 1) != "}") { print ""; exit 2 }
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
    # decode \" \\ \t \n; \u / dangling escape / unterminated string -> fail closed
    rest = substr(buf, i + 1)
    out = ""; esc = 0; closed = 0
    for (k = 1; k <= length(rest); k++) {
      c = substr(rest, k, 1)
      if (esc) {
        if (c == "u") { print ""; exit 2 }
        if (c == "\"") out = out "\""
        else if (c == "\\") out = out "\\"
        else if (c == "t") out = out "\t"
        else if (c == "n") out = out "\n"
        else out = out "\\" c
        esc = 0
      } else if (c == "\\") esc = 1
      else if (c == "\"") { closed = 1; break }
      else out = out c
    }
    if (esc || !closed) { print ""; exit 2 }
    print out
  }')
fi
if [ -z "$CMD" ]; then
  echo "BLOCKED by pit-stop: could not extract the command to check (jq missing or unparseable input)." >&2
  exit 2
fi

# Multi-line commands: a destructive op on a later line must not slip past the
# command-position boundary. jq on Windows emits CRLF, so strip CR first, then
# turn real newlines into `;` before matching.
CMD="${CMD//$'\r'/}"
CMD="${CMD//$'\n'/;}"

BLOCKED=""
case "$CMD" in
  *":(){ :|:& };:"*) BLOCKED="destructive command" ;;
esac

# rm in command position: start of command or after &&/;/|/(, with an optional
# prefix (do / command / env / nohup / time / xargs / sudo — flags allowed on all
# but `do` and `command`; value-taking ones may consume a flag value like `-u root`), an
# optional path (`/bin/rm`) or leading backslash, then `rm`. Mentions in
# arguments (grep rm, man rm, commit messages, quoted strings) pass.
RM_FLAG='[[:space:]]+-[^ ]+([[:space:]]+[^ -][^ ]*)?'
RM_PREFIX="(sudo(${RM_FLAG})*|do|command|env(${RM_FLAG})*|nohup([[:space:]]+-[^ ]+)*|xargs(${RM_FLAG})*|time([[:space:]]+-[^ ]+)*)"
RM_RE="(^|[;&|(])([[:space:]]*${RM_PREFIX})?[[:space:]]*([[:graph:]]*/)?[\\]?rm([[:space:]]|$)"
if [[ "$CMD" =~ $RM_RE ]]; then
  BLOCKED="file deletion (rm)"
fi

# destructive git subcommands in command position only — a mention in a message
# or an argument (grep "git push", commit messages) does not trigger.
GIT_SUBS='(push|reset([[:space:]]+-[^ ]+)*[[:space:]]+--hard|clean[[:space:]]+-f[dx]*|branch([[:space:]]+-[^ ]+)*[[:space:]]+-D|checkout([[:space:]]+-[^ ]+)*[[:space:]]+\.|restore([[:space:]]+-[^ ]+)*[[:space:]]+\.|rm)'
GIT_RE="(^|[;&|(])[[:space:]]*(${RM_PREFIX}[[:space:]]+)?([[:graph:]]*/)?[\\]?git([[:space:]]+-[^ ]+)*[[:space:]]+${GIT_SUBS}([[:space:]]|$)"
if [[ "$CMD" =~ $GIT_RE ]]; then
  BLOCKED="destructive git command"
fi

# non-git VCS force push (`hg push --force`, `hg -R x push -f`) and find
# destruction (`-delete`, `-exec[dir] rm`) — command position only, so mentions
# in messages and quoted strings pass.
PUSH_RE="(^|[;&|(])[[:space:]]*(${RM_PREFIX}[[:space:]]+)?([[:graph:]]*/)?[\\]?(hg|svn|bzr|fossil|pijul|darcs)(${RM_FLAG})*[[:space:]]+push[[:space:]]+(--force|-f)([[:space:]]|$)"
if [[ "$CMD" =~ $PUSH_RE ]]; then
  BLOCKED="force push"
fi
FIND_RE="(^|[;&|(])[[:space:]]*(${RM_PREFIX}[[:space:]]+)?([[:graph:]]*/)?[\\]?find([[:space:]]+[^ ]+)*[[:space:]]+(-delete|-exec(dir)?[[:space:]]+rm)([[:space:]]|$)"
if [[ "$CMD" =~ $FIND_RE ]]; then
  BLOCKED="file deletion (find)"
fi

if [ -n "$BLOCKED" ]; then
  echo "BLOCKED by pit-stop: '$CMD' matches $BLOCKED. Destructive ops need the human's explicit word." >&2
  exit 2
fi
exit 0
