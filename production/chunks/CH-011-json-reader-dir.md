# CH-011 JsonReader.read_dir

**Story:** DAT-001
**Goal:** read every `*.json` in one `res://` folder, keyed by file stem (knob tables, content tables, rules).
**Depends:** CH-010
**Parallel-safe with:** every batch-2 ticket except CH-010
**Files:** `src/data/json_reader.gd` (edit: add 1 func), `tests/unit/data/json_reader_test.gd` (edit: append),
`tests/unit/data/fixtures/dir/a.json`, `b.json`, `notes.txt` (new)

## API (add)

```gdscript
const DEFAULT_MAX_BYTES := 262144    # 256 KB per internal data file; ADR-0005 caps untrusted levels separately

static func read_dir(res_dir: String, max_bytes: int = DEFAULT_MAX_BYTES) -> Dictionary
	## {"files": Dictionary[StringName, Dictionary] (stem -> data), "errors": PackedStringArray}. res:// only.
```

> Deviation note: the plan's signature returns `Dictionary[StringName, Dictionary]` with no error channel. One bad file
> would then be silent, so this returns `{files, errors}`; callers use `["files"]`. Logged in the README plan-gap list.

## Behaviour

- `res_dir` must start with `"res://"` -> else errors `["<dir>: only res:// folders are read"]`, no files.
- `DirAccess.get_files_at(res_dir)`; keep names ending `.json` (also accept `.json.remap`? **no** — not needed for JSON in res://); sort names for determinism.
- Each file through `read_file`; ok -> `files[StringName(stem)] = data`; else append its error.
- Missing folder -> errors `["<dir>: not found"]`.

## Fixtures
`dir/a.json` = `{"x": 1}`, `dir/b.json` = `{"y": 2}`, `dir/notes.txt` = `ignore me`.

## Tests to write first (append)

1. `test_read_dir_keys_by_stem` — `read_dir("res://tests/unit/data/fixtures/dir")`: `files.keys()` sorted == `[&"a", &"b"]`, no errors.
2. `test_read_dir_rejects_user_path` — `read_dir("user://x")` -> 1 error containing `"only res://"`.
3. `test_read_dir_missing` — `"res://tests/unit/data/fixtures/nope"` -> error containing `"not found"`.

## Run
`-a res://tests/unit/data` (README).

## Done when
README "Done when" + all json_reader tests green. Verify the `.json` fixtures still appear after `--import` (Godot does not import JSON; `get_files_at` must list them).
