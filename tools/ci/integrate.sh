#!/usr/bin/env bash
# usage: integrate.sh <staging-dir> <target-dir> [--force]
# Moves staged files into target (keeping subpaths), then imports and reports parse errors for them.
cd "$(dirname "$0")/../.." || exit 2
S="${1:?usage: integrate.sh <staging-dir> <target-dir> [--force]}"; T="${2:?target}"; F="$3"
[ -d "$S" ] || { echo "no staging dir $S"; exit 2; }
files=$(cd "$S" && find . -type f ! -name .gdignore | sed 's|^\./||')
[ -n "$files" ] || { echo "nothing staged in $S"; exit 0; }
clash=$(while IFS= read -r f; do [ -e "$T/$f" ] && echo "$f"; done <<< "$files")
if [ -n "$clash" ] && [ "$F" != "--force" ]; then
  echo "ABORT: would overwrite in $T (use --force):"; echo "$clash"; exit 3
fi
while IFS= read -r f; do mkdir -p "$(dirname "$T/$f")"; mv -f "$S/$f" "$T/$f"; done <<< "$files"
echo "moved $(echo "$files" | wc -l) file(s) to $T"
out=$(tools/ci/import.sh); rc=$?
pat=$(echo "$files" | grep -E '\.gd$' | xargs -r -n1 basename | paste -sd'|')
if [ -n "$pat" ]; then echo "$out" | grep -E "$pat" || echo "no parse errors in moved files"; fi
echo "import exit=$rc"
exit $rc
