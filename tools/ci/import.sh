#!/usr/bin/env bash
# Serialised `godot --import`. Prints only parse/script error lines. Exit = godot's exit.
cd "$(dirname "$0")/../.." || exit 2
G="$("$(dirname "$0")/godot.sh")"
LOCK=.godot-import.lock
until mkdir "$LOCK" 2>/dev/null; do
  # stale after 10 min (holder crashed)
  [ -n "$(find "$LOCK" -maxdepth 0 -mmin +10 2>/dev/null)" ] && rmdir "$LOCK" 2>/dev/null
  sleep 2
done
trap 'rmdir "$LOCK" 2>/dev/null' EXIT
mkdir -p .godot
"$G" --headless --path . --import > .godot/import.log 2>&1
rc=$?
[ $rc -eq 0 ] && touch .godot/import.stamp
# one line per error with its location; addons/ noise is only counted
awk '/SCRIPT ERROR|Parse Error/{m=$0; next} m&&/at: /{ if (index($0,"res://addons/")) n++; else print m " " $0; m=""} END{if(n) print "(" n " addons/ errors hidden)"}' .godot/import.log
exit $rc
