#!/usr/bin/env bash
# usage: test.sh <res-path> [report-name]   e.g. test.sh res://tests/unit/rng CH-007
cd "$(dirname "$0")/../.." || exit 2
P="${1:?usage: test.sh <res-path> [report-name]}"
N="${2:-adhoc-$$}"
G="$(tools/ci/godot.sh)"
STAMP=.godot/import.stamp
if [ ! -f "$STAMP" ] || [ -n "$(find src tests addons -name '*.gd' -newer "$STAMP" -print -quit 2>/dev/null)" ]; then
  tools/ci/import.sh || { echo "import failed"; }
fi
mkdir -p reports
LOG="reports/$N.log"
"$G" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a "$P" -rd "res://reports/$N" > "$LOG" 2>&1
rc=$?
if grep -q "No test cases found" "$LOG"; then
  echo "FAIL: no test cases found for $P (exit=$rc)"; [ $rc -eq 0 ] && rc=1
else
  echo "$(grep -E 'Overall Summary' "$LOG" | tail -1 | sed 's/\x1b\[[0-9;]*m//g') exit=$rc"
fi
# failing test names + parse errors
sed 's/\x1b\[[0-9;]*m//g' "$LOG" | grep -E "FAILED|ERROR\b.*(Parse|SCRIPT)|SCRIPT ERROR|Parse Error" | head -40
exit $rc
