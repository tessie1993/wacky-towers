#!/usr/bin/env bash
# Resolves a pinned local engine or a user's explicit GODOT override.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
if [ -n "${GODOT:-}" ]; then
  echo "$GODOT"
elif [ -x "$ROOT/../tools/bin/godot" ]; then
  echo "$ROOT/../tools/bin/godot"
elif command -v godot >/dev/null 2>&1; then
  command -v godot
elif command -v godot4 >/dev/null 2>&1; then
  command -v godot4
else
  echo "Godot 4.7.2 is required. Set GODOT to its executable." >&2
  exit 2
fi
