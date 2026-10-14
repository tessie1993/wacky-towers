#!/bin/bash

# --- work from the project root ----------------------------------------------
# Same root resolution as the other hooks (see session-stop.sh for why the
# precedence order matters).
if [ -f "project.yaml" ] || [ -d ".claude" ]; then
  CCGS_ROOT="$PWD"
elif [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "${CLAUDE_PROJECT_DIR}" ]; then
  CCGS_ROOT="$CLAUDE_PROJECT_DIR"
else
  CCGS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
fi
[ -n "$CCGS_ROOT" ] && cd "$CCGS_ROOT" 2>/dev/null || true

# Claude Code Stop hook: reference quality gate.
#
# The user's bar (2026-10-14): every player-visible part of the game -- art,
# UI, levels, mechanics feel, sound -- must reach the quality of the reference
# boards in assets/art/reference/. See .claude/docs/reference-quality-bar.md.
#
# This hook emits an OBSERVATION, not a verdict (CLAUDE.md: helpers in
# .claude/ emit observations). It reports whether player-visible files changed
# after the newest strict review report. Whether the work is good enough is
# decided by the reviewer agents, never by this script.
#
# Blocks the stop once (exit 2) when player-visible changes are newer than the
# newest review report; never blocks twice in a row (stop_hook_active guard).

INPUT=$(cat 2>/dev/null || true)
if printf '%s' "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

# Player-visible surfaces.
VISIBLE_PATHS="src/ui src/view src/levels assets/art assets/models assets/audio assets/data/biome_looks.json assets/data/story"
# Strict review reports written by the reviewer panel.
REVIEW_GLOBS="production/qa/quality-review/*.md production/qa/*critique*.md"

newest_mtime() {
  # Prints the newest mtime (epoch seconds) among files under the given paths,
  # ignoring Godot .import/.uid sidecars. Prints 0 when nothing matches.
  local newest=0 t
  while IFS= read -r t; do
    [ -n "$t" ] && [ "${t%.*}" -gt "$newest" ] && newest="${t%.*}"
  done < <(find "$@" -type f ! -name '*.import' ! -name '*.uid' -printf '%T@\n' 2>/dev/null)
  echo "$newest"
}

# shellcheck disable=SC2086
VISIBLE_TS=$(newest_mtime $VISIBLE_PATHS)
REVIEW_TS=0
for f in $REVIEW_GLOBS; do
  [ -f "$f" ] || continue
  t=$(stat -c %Y "$f" 2>/dev/null || echo 0)
  [ "$t" -gt "$REVIEW_TS" ] && REVIEW_TS="$t"
done

if [ "$VISIBLE_TS" -gt "$REVIEW_TS" ]; then
  {
    echo "REFERENCE QUALITY GATE: player-visible files changed after the newest strict review"
    echo "(newest change $(date -d "@$VISIBLE_TS" '+%F %T' 2>/dev/null), newest review $( [ "$REVIEW_TS" -gt 0 ] && date -d "@$REVIEW_TS" '+%F %T' || echo none))."
    echo "Before calling this work done, have the reviewer panel judge it against assets/art/reference/"
    echo "(art, UI, levels, mechanics feel, sound; bar: >= 8/10 per item, zero beige/parchment UI)."
    echo "Reviews go to production/qa/quality-review/<date>-<area>.md. Then act on their fixes."
    echo "See .claude/docs/reference-quality-bar.md."
  } >&2
  exit 2
fi
exit 0
