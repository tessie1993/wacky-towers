#!/usr/bin/env bash
# Reuse-first reminder (user rule 2026-10-15): before building something from
# scratch, look at what the project already has that can help.
# PreToolUse (Write of a NEW file, or a Bash call that runs Blender) and SubagentStart.
# Emits observations only (additionalContext); never blocks.
set -u
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
input="$(cat)"
event="$(printf '%s' "$input" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("hook_event_name",""))' 2>/dev/null)"

stem=""
if [ "$event" = "PreToolUse" ]; then
  read -r tool path cmd < <(printf '%s' "$input" | python3 -c '
import sys,json
d=json.load(sys.stdin); t=d.get("tool_name",""); i=d.get("tool_input",{})
print(t, i.get("file_path","-") or "-", "blender" if "blender" in str(i.get("command","")) else "-")' 2>/dev/null)
  if [ "$tool" = "Write" ]; then
    [ -e "$path" ] && exit 0                       # editing an existing file: nothing to say
    case "$path" in "$root"/src/*|"$root"/assets/*|"$root"/tools/*|"$root"/tests/*) ;; *) exit 0;; esac
    stem="$(basename "$path" | sed 's/\.[^.]*$//')"
  elif [ "$tool" = "Bash" ] && [ "$cmd" = "blender" ]; then
    stem="blender"
  else
    exit 0
  fi
fi

# Similar existing files: any word (>=4 chars) of the new name.
similar=""
if [ -n "$stem" ] && [ "$stem" != "blender" ]; then
  words="$(printf '%s' "$stem" | tr '_-' '\n\n' | awk 'length>=4' | head -4 | paste -sd'|')"
  [ -n "$words" ] && similar="$(cd "$root" && git ls-files src assets tools tests 2>/dev/null | grep -Ei "$words" | grep -v '\.import$\|\.uid$' | head -8 | paste -sd' ')"
fi

msg="REUSE FIRST (user rule): before building from scratch, check what already exists and adapt it.
- Skills: .claude/skills/ ($(ls "$root/.claude/skills" 2>/dev/null | wc -l | tr -d ' ') skills; godot-*, gamedev-*, blender-reference-modeling-*). grep the folder names for your topic and read the SKILL.md.
- Godot addons: $(ls "$root/addons" 2>/dev/null | paste -sd' ').
- Asset library (CC0 originals): assets/library/; meshes: assets/models/ (env_v3, characters, levels); assets/third_party/ (kenney_nature_kit, CREDITS.md); textures: assets/textures/.
- Outside sources: PolyHaven (api.polyhaven.com), free CC0 BlenderKit, Blender add-ons/extensions, online references and tutorials. Save downloaded originals to assets/library/<kind>/<source>/<name>/ with LICENSE.txt.
- Code: reuse existing rules (src/mechanics/), view/FX (src/view/), UI kit (src/ui/common/) and data knobs (assets/data/)."
[ -n "$similar" ] && msg="$msg
- Existing files with similar names: $similar"

python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":sys.argv[1],"additionalContext":sys.argv[2]}}))' "${event:-PreToolUse}" "$msg"
exit 0
