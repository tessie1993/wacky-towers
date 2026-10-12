#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
G="$(tools/ci/godot.sh)"
exec "$G" --path . "$@"
