# Coding chunks (tickets)

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
| CH-004 | BRD-001 | BoardState stub: Down enum + token/vector helpers | none | A | todo |
| CH-005 | BRD-001 | AsciiGrid.parse_mask | none | A | todo |
| CH-006 | BRD-001 | AsciiGrid.parse_layers | CH-005 | B | todo |
| CH-007 | BRD-001 | BoardSpec + BoardSpecResult: parse part 1 | CH-002, CH-003, CH-004, CH-005 | B | todo |
| CH-008 | BRD-001 | BoardSpec.parse part 2: contents + anchor | CH-006, CH-007 | C | todo |
| CH-009 | BRD-001 | BoardSpec fuzz test | CH-008 | D | todo |

Group A = 5 tickets in parallel; B = 2 in parallel; then C, then D. No two tickets in
the same group edit the same file. A ticket may start as soon as its own deps are `done`.
Next: Wave 2 (SHP-002 rest, BRD-002, SIM-001).

## Status — batch 2 (Wave 1: DAT-001, RUL-001, VEW-004; + SHP-002 part 1)

| ID | Story | Title | Depends | Group | Status |
|----|-------|-------|---------|-------|--------|
| CH-010 | DAT-001 | JsonReader: whole_int + read_file | none | E | todo |
| CH-012 | DAT-001 | KnobDefs: build + validate tables | none | E | todo |
| CH-015 | DAT-001 | Knob files: board, view, data | none | E | todo |
| CH-016 | DAT-001 | Knob files: fall, spawn, controls | none | E | todo |
| CH-017 | DAT-001 | Knob files: clearing, goals, rules | none | E | todo |
| CH-019 | RUL-001 | Value types (HookContext, VetoResult, ClearGroup, ArrivalPlan) + RuleApi stub | none | E | todo |
| CH-020 | SHP-002 | ShapeDef resource: fields + accessors | none | E | todo |
| CH-023 | VEW-004 | CameraMath: yaw, screen-to-world, tilt/roll | none | E | todo |
| CH-011 | DAT-001 | JsonReader.read_dir | CH-010 | F | todo |
| CH-013 | DAT-001 | KnobDefs.coerce + last_error | CH-012 | F | todo |
| CH-021 | RUL-001 | Abstract bases: RuleBehaviour, ClearDetector, CollapsePolicy, ArrivalStyle | CH-019, CH-020, CH-004 | F | todo |
| CH-024 | VEW-004 | CameraMath.ortho_size | CH-023 | F | todo |
| CH-014 | DAT-001 | KnobRegistry: base values | CH-013 | G | todo |
| CH-022 | RUL-001 | PluginRegistry | CH-021 | G | todo |
| CH-025 | VEW-004 | CameraRig: 12 snaps, framing, tween + screenshots | CH-024 | G | todo |
| CH-018 | DAT-001 | knob_files_test | CH-011, CH-013, CH-015, CH-016, CH-017 | H | todo |

Batch-2 groups run E -> F -> G -> H and share no files with batch 1, so group E can start
alongside batch-1 groups B–D. Not yet ticketed: RUL-001 bases GoalEvaluator, TopOutPolicy,
ControlVerb, LayoutKind and `validate()` on every base (blocked on plan gaps 4–5); Wave 2.

## Plan gaps / deviations (for the architecture lead)

Accepted by the coordinator 2026-10-10: 1–3. Open: 4–9.

1. **BoardLimits.spawn_clearance** (CH-002): board height = `h_play + C` (Board GDD F4); the level loader sets C = L_max later.
2. **Whole-number rule** is private `_whole_int` in `BoardSpec` (core may not import `data/`). Batch 2 adds two more copies
   (`JsonReader.whole_int`, `KnobDefs._whole_int`); the third copy is marked `ponytail:`. Extract one core helper if a fourth appears.
3. **ascii_grid tests** live in `tests/unit/board_grid/` next to `core/board/ascii_grid.gd` (plan's BRD-001 file list says `tests/unit/data/`).
4. **Base `validate()` returns `Array[ValidationIssue]`**, but `ValidationIssue` is in `src/data/`, which `core/rules` and `gameplay`
   may not import. Proposal: `validate(level, catalog) -> PackedStringArray` (as `LayoutKind.validate` already does); the validator wraps the strings.
5. **`GoalEvaluator` (GoalState) and `ControlVerb` (SimCommand) bases** in `core/rules` name `core/sim` types; the layering table
   forbids `core/rules -> core/sim`. Proposal: move `SimCommand`, `SimEvent`, `GoalState` (plain value types) to `core/model`, or allow them explicitly.
6. **`JsonReader.read_dir`** returns `{files, errors}` instead of a bare Dictionary, so a bad file is not silent (CH-011).
7. **PluginRegistry kind = base class name** (`&"ClearDetector"`); kinds are discovered as classes under `src/core/rules/bases/`, no kind list (CH-022).
8. **ShapeDef fields pulled forward** from SHP-002 (CH-020) because `ArrivalStyle` names `ShapeDef`.
9. **BoardLimits knobs** live in `knobs/board.json` as `board.min_side` …; APP-001 strips the `board.` prefix for `BoardLimits.from_dict`.

Status values: `todo` -> `in-progress (agent)` -> `done` (tests green) or `blocked (reason)`.
Edit only your own row.

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
- Write the listed tests first, run them red, then implement until green.

## Run

New `class_name` files need the global class cache refreshed once:

```
"D:/TESSA/Godot_v4.7.2-stable_win64.exe (2)/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --import
```

Then run the system's tests (from the repo root):

```
"D:/TESSA/Godot_v4.7.2-stable_win64.exe (2)/Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/<system> --ignoreHeadlessMode
```

`<system>` is `shapes`, `board_grid`, `data`, `rules` or `view`. Also run `rng` once before
marking done, to prove nothing else broke.

## Done when (all tickets)

1. Every listed test exists and passes; the whole `<system>` folder is green.
2. No parse warnings for your files in the run output.
3. Every public method has a `##` doc comment.
4. Status row updated. No commit unless the orchestrator asks.
