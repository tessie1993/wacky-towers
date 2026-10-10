# CH-018 knob_files_test: every knob file loads and is valid

**Story:** DAT-001
**Goal:** a guard that fails when any `assets/data/knobs/*.json` is malformed, has a duplicate id, or a default outside its range.
**Depends:** CH-011 (read_dir), CH-013 (KnobDefs complete), CH-015, CH-016, CH-017 (the files)
**Parallel-safe with:** everything not editing knob files or knob_defs.gd
**Files:** `tests/unit/data/knob_files_test.gd` (new). Test only.

## Tests

1. `test_all_knob_files_parse` — `JsonReader.read_dir("res://assets/data/knobs")`: no errors; `files.keys()` sorted ==
   `[&"board", &"clearing", &"controls", &"data", &"fall", &"goals", &"rules", &"spawn", &"view"]`.
2. `test_knob_tables_build_without_errors` — `KnobDefs.from_tables(files.values())` -> `errors()` empty
   (this covers unique ids, defaults inside ranges, choices, types). On failure print the error list.
3. `test_every_default_coerces` — for every id: `coerce(id, <raw default from the JSON entry>)` is not null
   (proves the JSON default survives the same path a level override takes).
4. `test_meadow_slot_knobs_exist` — `has()` for `&"clear.detector"`, `&"clear.collapse"`, `&"spawn.arrival"`, `&"goal.type"`,
   `&"goal.top_out"`, `&"control.verb"`, each of type `&"slot"`.

If a test fails because of a data file, do **not** edit the file here: set status `blocked (knob file X: error)`; the owner of CH-015/016/017 fixes it.

## Run
`-a res://tests/unit/data` (README).

## Done when
README "Done when" + 4 tests green.
