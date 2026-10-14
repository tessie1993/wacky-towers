#!/bin/bash

# --- work from the project root (same resolution as the other hooks) ----------
if [ -f "project.yaml" ] || [ -d ".claude" ]; then
  CCGS_ROOT="$PWD"
elif [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "${CLAUDE_PROJECT_DIR}" ]; then
  CCGS_ROOT="$CLAUDE_PROJECT_DIR"
else
  CCGS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
fi
[ -n "$CCGS_ROOT" ] && cd "$CCGS_ROOT" 2>/dev/null || true

# Claude Code Stop hook: clickable questions.
#
# User rule (2026-10-14): "clickable questions always". A question for the user goes through
# the AskUserQuestion tool (clickable options), never as plain "?" text at the end of a reply.
#
# Observes the turn since the user's last message. If the final assistant text asks the
# user something (a line ending in "?") and no AskUserQuestion call was made in the turn,
# it blocks the stop once (exit 2). It never blocks twice in a row.

INPUT=$(cat 2>/dev/null || true)
printf '%s' "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
command -v python3 >/dev/null 2>&1 || exit 0

printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    path = data.get("transcript_path") or ""
    rows = [json.loads(l) for l in open(path, encoding="utf-8") if l.strip()]
except Exception:
    sys.exit(0)

def content(row):
    c = (row.get("message") or {}).get("content")
    return c if isinstance(c, list) else ([{"type": "text", "text": c}] if isinstance(c, str) else [])

# Start of the turn: the last user row that is a real prompt (not only tool results).
start = 0
for i, row in enumerate(rows):
    if row.get("type") == "user" and not row.get("isSidechain"):
        if any(b.get("type") == "text" for b in content(row)):
            start = i
asked = False
last_text = ""
for row in rows[start + 1:]:
    if row.get("type") != "assistant" or row.get("isSidechain"):
        continue
    for b in content(row):
        if b.get("type") == "tool_use" and b.get("name") == "AskUserQuestion":
            asked = True
        elif b.get("type") == "text" and b.get("text", "").strip():
            last_text = b["text"]
if asked or not last_text:
    sys.exit(0)
# Only lines outside code fences that end in "?" count as questions to the user.
fence = False
questions = []
for line in last_text.splitlines():
    s = line.strip()
    if s.startswith("```"):
        fence = not fence
        continue
    if not fence and s.rstrip("*_ )").endswith("?"):
        questions.append(s)
if questions:
    sys.stderr.write(
        "CLICKABLE QUESTIONS: your reply asks the user %d question(s) as plain text, e.g. \"%s\".\n"
        "User rule: questions go through the AskUserQuestion tool with clickable options "
        "(recommended option first). Ask them that way now.\n" % (len(questions), questions[0][:120]))
    sys.exit(2)
sys.exit(0)
'
