#!/bin/bash
# pit-stop L2 guardrail: PreToolUse hook blocking destructive git/shell commands.
# Install (Claude Code): project `.claude/settings.json` or global `~/.claude/settings.json`,
# matcher Bash, command = path to this file. Blocked tool exits 2 with a refusal note.
# Pure bash + sed (no jq/grep dependency). Fails closed: if the command cannot be
# extracted, the call is blocked rather than silently passed.
INPUT=$(cat)

# extract .tool_input.command
CMD=""
if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  CMD=$(printf '%s' "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi
if [ -z "$CMD" ]; then
  echo "BLOCKED by pit-stop: could not extract the command to check (jq missing or unexpected input)." >&2
  exit 2
fi

BLOCKED=""
case "$CMD" in
  *"git push"*|*"push --force"*|*"git reset --hard"*|*"reset --hard"*|*"git clean -f"*|*"git branch -D"*|*"git checkout ."*|*"git restore ."*|*"git rm "*|*" -delete"*|*":(){ :|:& };:"*)
    BLOCKED="destructive git/shell command" ;;
esac
RM_RE='(^|[;&|(])([[:space:]]*(sudo|do|command))?[[:space:]]*rm([[:space:]]|$)'
if [[ "$CMD" =~ $RM_RE ]]; then
  BLOCKED="file deletion (rm)"
fi
if [ -n "$BLOCKED" ]; then
  echo "BLOCKED by pit-stop: '$CMD' matches $BLOCKED. Destructive ops need the human's explicit word." >&2
  exit 2
fi
exit 0
