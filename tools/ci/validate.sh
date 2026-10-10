#!/usr/bin/env bash
# Engine import exits zero for some script errors: fail on their observed log too.
set -euo pipefail
cd "$(dirname "$0")/../.."
G="$(tools/ci/godot.sh)"
mkdir -p reports
"$G" --headless --editor --path . --import > reports/import.log 2>&1
if rg -n 'SCRIPT ERROR|Parse Error|Failed to load script' reports/import.log; then
  exit 1
fi
"$G" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests -rd res://reports/full > reports/tests.log 2>&1
if rg -n 'SCRIPT ERROR|Parse Error|No test cases found' reports/tests.log; then
  exit 1
fi
rg 'Overall Summary|Test suites|Test cases|passed|failed' reports/tests.log | tail -20
