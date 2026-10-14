# Godot master consult protocol

User rule, 2026-10-14: "help the other agents, make them ask you questions."

The orchestrator (main session) acts as the **Godot master**, using `.claude/skills/godot-master/SKILL.md`.
Every subagent **asks before it guesses** on a Godot or architecture decision.

## When to ask (stop and ask; do not improvise)

- Which node, server or resource type to use, or where state should live (the "who owns what" check).
- Any engine API you are not sure exists in 4.7.2. Check `docs/engine-reference/` first, then ask.
  Recent examples: `step()` in GDScript and `ShaderMaterial.duplicate()` losing arrays.
- Cross-file or cross-owner changes, such as touching a file another agent owns.
- Performance trade-offs: MultiMesh vs nodes, `_process` polling, runtime `material.duplicate()`,
  `load()` in hot paths.
- Anything that might break CI. Warnings are errors in CI, so never infer a type from a Variant
  with `:=`.
- Design ambiguity that changes the result (narrative, levels, art direction).

## How to ask

- If you can message the main session, send your questions there and wait for the answer.
- If you cannot, end your turn early with a section titled **`QUESTIONS FOR GODOT MASTER`**.
  Number the questions. Give each one 2–3 options and say which you recommend. Put this section
  before your report. The orchestrator answers and resumes you.
- Batch your questions: ask several at once rather than one per turn.

## Standing answers (apply without asking)

- Signals go up, calls go down. Presentation never mutates data.
- Prefer `RefCounted` or `Resource` over `Node` for logic and data.
- Use static typing everywhere. No untyped `:=` from a Variant. Use `StringName` for hot keys.
- No `material.duplicate()` per instance at runtime. Use instance shader parameters, or one material
  per variant.
- MultiMesh for repeated props. No `get_nodes_in_group()` or `load()` in `_process`.
- Keep values data-driven in `assets/data/*.json`.
- After every batch of edits, run `godot --headless --path . --import` and check for "Parse Error",
  then run `ui_flow_smoke`. Do not run the full gdUnit suite (user rule).

## Godot builder: who writes Godot code (user, 2026-10-14)

User: "you are in charge of coding in Godot." The main session is the **Godot builder**
(`.claude/skills/godot-builder/SKILL.md`):
- Subagents design, prototype and test in a **sandbox copy** (or write new files only where they are
  told to). They hand back an **overlay plus patch scripts** and evidence, as the world agent does.
- The builder reviews each patch, applies it to the live repo, runs `tools/build/check.sh` (isolated XDG
  cache, import parse check, `ui_flow_smoke`, campaign verifier) and commits only on CHECK PASS.
- Data-only level JSON work may still be written directly by level agents, but it must pass
  `tools/build/check.sh` before commit.
- Builder rules: isolate XDG for concurrent Godot runs, end headless scripts with `quit()`, set the
  `owner` of generated scene nodes, prefer `uid://` loads, no `duplicate(true)` (use `duplicate_deep`),
  and run a headless `--import` after generating resources.

## Architecture

Follow `docs/architecture/composition-guide.md` (composition over inheritance, WtStage as an
orchestrator, the planned components for the scene kit, goal phases and bosses, and the patch
checklist). Proposing a new component? Name it and place it in the guide's tables, and ask the Godot
master if it doesn't fit.
