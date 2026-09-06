#!/bin/bash
# pit-stop L2 guardrail: PreToolUse hook blocking destructive git/shell commands.
# Install (Claude Code): project `.claude/settings.json` or global `~/.claude/settings.json`,
# matcher Bash, command = path to this file. Blocked tool exits 2 with a refusal note.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')
DANGEROUS_PATTERNS=(
  "git push"
  "push --force"
  "git reset --hard"
  "reset --hard"
  "git clean -f"
  "git branch -D"
  "git checkout \."
  "git restore \."
  "rm -rf /"
  "rm -rf ~"
  ":(){ :|:& };:"
)
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED by pit-stop: '$COMMAND' matches '$pattern'. Destructive ops need the human's explicit word." >&2
    exit 2
  fi
done
exit 0
