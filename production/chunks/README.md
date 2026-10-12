# Coding chunks (tickets)

> **NO TESTS (user rule 2026-10-10).** Ignore every "tests first", "Tests to write FIRST", gdUnit and test-file instruction in this file and in the tickets. Writers write game code only; the integrator proves each chunk in the editor (script eval + `logs_read`, or run the scene + screenshot). New tickets: `README-batch5.md`.

Tiny, self-contained coding tickets. One Sonnet coder takes one ticket, writes the
tests first, then the code, runs the suite, and flips the status.
Source of truth: `docs/architecture/implementation-plan.md` (class names, file paths,
wave order) and the ADRs it cites. Every ticket is tagged with its plan story ID.
FND-001 (RNG, `Seeds`) is done.

## Status — batch 1 (Wave 1: SHP-001, BRD-001)

| ID | Story | Title | Depends | Group | Status |
|----|-------|-------|---------|-------|--------|
| CH-001 | SHP-001 | Orientations: 24 integer rotations, apply, turn | none | A | done |
| CH-002 | BRD-001 | BoardLimits: hard caps | none | A | done |
| CH-003 | BRD-001 | ContentTypes + content/blocks.json | none | A | done |
| CH-004 | BRD-001 | BoardState stub: Down enum + token/vector helpers | none | A | done |
| CH-005 | BRD-001 | AsciiGrid.parse_mask | none | A | done |
| CH-006 | BRD-001 | AsciiGrid.parse_layers | CH-005 | B | done |
| CH-007 | BRD-001 | BoardSpec + BoardSpecResult: parse part 1 | CH-002, CH-003, CH-004, CH-005 | B | done |
| CH-008 | BRD-001 | BoardSpec.parse part 2: contents + anchor | CH-006, CH-007 | C | done |
| CH-009 | BRD-001 | BoardSpec fuzz test | CH-008 | D | dropped (no-tests rule) |

Group A = 5 tickets in parallel; B = 2 in parallel; then C, then D. No two tickets in
the same group edit the same file. A ticket may start as soon as its own deps are `done`.
Next: Wave 2 (SHP-002 rest, BRD-002, SIM-001).

## Status — batch 2 (Wave 1: DAT-001, RUL-001, VEW-004; + SHP-002 part 1)

| ID | Story | Title | Depends | Group | Status |
|----|-------|-------|---------|-------|--------|
| CH-010 | DAT-001 | JsonReader: whole_int + read_file | none | E | done |
| CH-012 | DAT-001 | KnobDefs: build + validate tables | none | E | done |
| CH-015 | DAT-001 | Knob files: board, view, data | none | E | done |
| CH-016 | DAT-001 | Knob files: fall, spawn, controls | none | E | done |
| CH-017 | DAT-001 | Knob files: clearing, goals, rules | none | E | done |
| CH-019 | RUL-001 | Value types (HookContext, VetoResult, ClearGroup, ArrivalPlan) + RuleApi stub | none | E | done |
| CH-020 | SHP-002 | ShapeDef resource: fields + accessors | none | E | done |
| CH-023 | VEW-004 | CameraMath: yaw, screen-to-world, tilt/roll | none | E | done |
| CH-011 | DAT-001 | JsonReader.read_dir | CH-010 | F | done |
| CH-013 | DAT-001 | KnobDefs.coerce + last_error | CH-012 | F | done |
| CH-021 | RUL-001 | Abstract bases: RuleBehaviour, ClearDetector, CollapsePolicy, ArrivalStyle | CH-019, CH-020, CH-004 | F | done |
| CH-024 | VEW-004 | CameraMath.ortho_size | CH-023 | F | done |
| CH-014 | DAT-001 | KnobRegistry: base values | CH-013 | G | done |
| CH-022 | RUL-001 | PluginRegistry | CH-021 | G | done |
| CH-025 | VEW-004 | CameraRig: 12 snaps, framing, tween + screenshots | CH-024 | G | done |
| CH-018 | DAT-001 | knob_files_test | CH-011, CH-013, CH-015, CH-016, CH-017 | H | in-progress (knob data fixed, rerun) |

Batch-2 groups run E -> F -> G -> H and share no files with batch 1, so group E can start
alongside batch-1 groups B–D. Not yet ticketed: RUL-001 bases GoalEvaluator, TopOutPolicy,
ControlVerb, LayoutKind and `validate()` on every base (blocked on plan gaps 4–5); Wave 2.

## Status — batch 3 (Wave 2: SHP-002, BRD-002, SIM-001)

| ID | Story | Title | Depends | Group | Status |
|----|-------|-------|---------|-------|--------|
| CH-026 | SHP-002 | ShapeDef.canonical_key | CH-001, CH-020 | I | done |
| CH-028 | SHP-002 | ShapeBank: lookup + ids | CH-020 | I | done |
| CH-029 | BRD-002 | BoardState storage: arrays, index, mask, contents | CH-003, CH-004, CH-007 | I | done |
| CH-032 | SIM-001 | SimCommand, SimEvent, SimEvents vocabulary | none | I | done |
| CH-033 | RUL-002 | RuleDef container | none | I | done |
| CH-027 | SHP-002 | ShapeDef.build: orientation tables, distinct, spawn | CH-026 | J | done |
| CH-030 | BRD-002 | BoardState layers: ordering + counters, 6 axes | CH-029 | J | done |
| CH-034 | DAT-002 | LevelData + GameCatalog containers | CH-002, CH-003, CH-007, CH-012, CH-022, CH-028, CH-033 | J | done |
| CH-031 | BRD-002 | BoardState queries: is_free, can_place, cast, stack, over_limit | CH-030 | K | done |
| CH-035 | SIM-001 | BoardSim skeleton: clock, phases, queue, pipeline | CH-032, CH-034 | K | done |
| CH-036 | SIM-001 | Replay | CH-035 | L | done |

## Status — batch 4b (from main: gap decisions + remaining RUL-001 bases)

Merged from main (PR #11), renumbered CH-037..041 → CH-148..152 because this branch's README-batch4.md already uses CH-037..147. Lead to reconcile the overlaps noted.

| ID | Story | Title | Depends | Group | Status |
|----|-------|-------|---------|-------|--------|
| CH-148 | DAT-002/SIM-004 | core/model: ValidationIssue + GoalState (+ confirm SimCommand/SimEvent in model) — overlaps CH-078, CH-043 | CH-032 | M | done |
| CH-149 | DAT-001 | JsonNum.whole_int extraction (refactor, gap 2) — superseded by CH-037 (applied on this branch) | CH-003, CH-008, CH-011, CH-013 | M | superseded |
| CH-150 | RUL-001 | validate() on the four existing bases | CH-021, CH-034, CH-148 | N | staged |
| CH-151 | RUL-001 | Bases: GoalEvaluator + TopOutPolicy — overlaps CH-043 | CH-021, CH-034, CH-148 | N | staged |
| CH-152 | RUL-001 | Bases: ControlVerb + LayoutKind | CH-021, CH-032, CH-034, CH-148 | N | staged |

## Plan gaps / deviations (for the architecture lead)

Accepted by the coordinator 2026-10-10: 1–3. All nine decided by the architecture lead 2026-10-10 (below); none open.

1. **BoardLimits.spawn_clearance** (CH-002): board height = `h_play + C` (Board GDD F4); the level loader sets C = L_max later.
   - **Decision (godot-specialist, 2026-10-10):** Accepted. `spawn_clearance` stays in `BoardLimits`; LevelLoader sets it per level to L_max of the level's piece set (plan §1.2).
2. **Whole-number rule** is private `_whole_int` in `BoardSpec` (core may not import `data/`). Batch 2 adds two more copies
   (`JsonReader.whole_int`, `KnobDefs._whole_int`); the third copy is marked `ponytail:`. Extract one core helper if a fourth appears.
   - **Decision (godot-specialist, 2026-10-10):** Changed: extract now, not at a fourth copy. One public helper `JsonNum.whole_int(v) -> Variant` in `src/core/board/json_num.gd`; `BoardSpec`, `KnobDefs` and `JsonReader` call it; delete the private copies (plan §1.2).
3. **ascii_grid tests** live in `tests/unit/board_grid/` next to `core/board/ascii_grid.gd` (plan's BRD-001 file list says `tests/unit/data/`).
   - **Decision (godot-specialist, 2026-10-10):** Accepted; the plan's BRD-001 test path is superseded.
4. **Base `validate()` returns `Array[ValidationIssue]`**, but `ValidationIssue` is in `src/data/`, which `core/rules` and `gameplay`
   may not import. Proposal: `validate(level, catalog) -> PackedStringArray` (as `LayoutKind.validate` already does); the validator wraps the strings.
   - **Decision (godot-specialist, 2026-10-10):** Rejected the PackedStringArray proposal (loses field/rule/severity). `ValidationIssue` moves to `src/core/model/`; every base's `validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]` keeps that type, `LayoutKind` included (plan §1.2). Unblocks the bases.
5. **`GoalEvaluator` (GoalState) and `ControlVerb` (SimCommand) bases** in `core/rules` name `core/sim` types; the layering table
   forbids `core/rules -> core/sim`. Proposal: move `SimCommand`, `SimEvent`, `GoalState` (plain value types) to `core/model`, or allow them explicitly.
   - **Decision (godot-specialist, 2026-10-10):** Move `SimCommand`, `SimEvent` and `GoalState` to `src/core/model/` (plain value types; `RuleRuntime.take_events()` needs `SimEvent` too). `core/rules` and `gameplay` may import `core/model`, so no layering exception. `SimEvents` (kind vocabulary), `BoardSim`, `Replay` stay in `core/sim` (plan §1.2, SIM-001, SIM-004).
6. **`JsonReader.read_dir`** returns `{files, errors}` instead of a bare Dictionary, so a bad file is not silent (CH-011).
   - **Decision (godot-specialist, 2026-10-10):** Accepted; plan §1.2 updated to `{files, errors}`.
7. **PluginRegistry kind = base class name** (`&"ClearDetector"`); kinds are discovered as classes under `src/core/rules/bases/`, no kind list (CH-022).
   - **Decision (godot-specialist, 2026-10-10):** Accepted; plan §1.2 `PluginRegistry.create` documents kind = base class name.
8. **ShapeDef fields pulled forward** from SHP-002 (CH-020) because `ArrivalStyle` names `ShapeDef`.
   - **Decision (godot-specialist, 2026-10-10):** Accepted.
9. **BoardLimits knobs** live in `knobs/board.json` as `board.min_side` …; APP-001 strips the `board.` prefix for `BoardLimits.from_dict`.
   - **Decision (godot-specialist, 2026-10-10):** Accepted.

Status values: `todo` -> `in-progress (agent)` -> `done` (tests green) or `blocked (reason)`.
Edit only your own row.

10. **Pulled forward as containers**: `RuleDef` (CH-033, RUL-002) and `LevelData`/`GameCatalog` (CH-034, DAT-002), because `BoardSim._init` names them.
11. **`ShapeDef.build(id, offsets)`** (CH-027) is not in the plan; the extractor (SHP-003) needs it.
12. **x/z height limit** (CH-031): `limit_layer = extent − C` (ADR-0002 Open Item 1) gives 0 on a 4-wide board with C = 4. Fine for Meadow (all −y); the designers need to settle it before sideways-gravity levels.

## Ticket format

Each `CH-NNN-<slug>.md` has: Goal, Depends, Parallel-safe with, Files, API (exact
signatures), Behaviour + edge cases, Tests to write FIRST (with expected values),
Run, Done when, Out of scope.

## Conventions (all tickets)

- GDScript, **static typing everywhere** (typed vars, params, returns, `Array[T]`).
- `##` doc comment on the class and every public method (what it does, one usage line).
- No magic numbers: named `const` with its source in a comment (`# ADR-0002 §2`).
- Core code (`src/core/**`) is `RefCounted` (or `Resource` where the ticket says):
  no nodes, signals, `await`, `Time`, or engine singletons.
- Never use global `randi`/`randf`/`randomize`/`hash()`; randomness comes from `Seeds`
  (`src/core/rng/seeds.gd`). None of batch 1 needs randomness.
- Methods named `_x` are private. Do not add public methods the ticket does not list.
- Do not touch files outside your ticket's Files list. Need a change elsewhere?
  Mark the ticket `blocked (needs X)` and stop.
- Tests: `tests/unit/<system>/<name>_test.gd`, `extends GdUnitTestSuite`, functions
  `test_<what>_<expected>()`, deterministic, no file I/O. Style reference:
  `tests/unit/rng/seeds_test.gd`. Loop over cases inside one test rather than
  copy-pasting tests.
- **View/app tickets** (scenes, `.tscn`, MultiMesh, camera, HUD, Main) end with **Verify in editor**: run the scene and save
  a screenshot to `production/qa/evidence/<ticket-id>.png` (Godot AI MCP if you have it; else `--write-movie` for a few frames,
  or a small `-s` script that grabs `get_viewport().get_texture().get_image()`). Headless runs cannot render: use the windowed exe.
- Write the listed tests first, run them red, then implement until green.

## Run

New `class_name` files need the global class cache refreshed once:

```
"D:/TESSA/Godot_v4.7.2-stable_win64.exe (2)/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --import
```

Then run the system's tests (from the repo root):

```
"D:/TESSA/Godot_v4.7.2-stable_win64.exe (2)/Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/<system> --ignoreHeadlessMode
```

`<system>` is `shapes`, `board_grid`, `data`, `rules`, `view`, `sim` or `model`. Also run `rng` once before
marking done, to prove nothing else broke.

## Done when (all tickets)

1. Every listed test exists and passes; the whole `<system>` folder is green.
2. No parse warnings for your files in the run output.
3. Every public method has a `##` doc comment.
4. Status row updated. No commit unless the orchestrator asks.
