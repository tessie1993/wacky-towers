# CH-010 JsonReader: whole_int + read_file

**Story:** DAT-001
**Goal:** the one safe way to read a JSON file: byte cap, never `ResourceLoader`, explicit result (ADR-0005; implementation-plan §1.2 `src/data/`).
**Depends:** none
**Parallel-safe with:** every other batch-2 ticket except CH-011
**Files:** `src/data/json_reader.gd` (new), `tests/unit/data/json_reader_test.gd` (new),
`tests/unit/data/fixtures/ok.json`, `bad.json`, `array_root.json` (new)

## API

```gdscript
class_name JsonReader extends RefCounted
## Reads JSON from disk with a size cap and never through ResourceLoader (ADR-0005).

const MAX_SAFE_INT := 2147483647     # same whole-number rule as BoardSpec._whole_int (README plan gap 2)

static func whole_int(v: Variant) -> Variant
	## int, or null when v is not a whole number. JSON numbers arrive as float (ADR-0002 Verification 1).
static func read_file(path: String, max_bytes: int) -> Dictionary
	## {"ok": bool, "data": Dictionary, "error": String}. Root must be an object.
```

## Behaviour

- `whole_int`: `int` -> itself; `float` -> `int(v)` only if finite, `v == floorf(v)`, `absf(v) <= MAX_SAFE_INT`; anything else (bool, String, null, …) -> null.
- `read_file` errors (`ok = false`, `data = {}`), in order:
  missing file -> `"<path>: not found"`; `FileAccess.get_file_as_bytes` / `FileAccess.open` failure -> `"<path>: cannot open"`;
  length > `max_bytes` -> `"<path>: <n> bytes over the cap <max>"` (check `FileAccess.get_length()` **before** reading the text);
  parse failure (use a `JSON` instance + `parse()` so you get the line) -> `"<path>: line <l>: <message>"`;
  root not a Dictionary -> `"<path>: root must be an object"`.
- Success: `{"ok": true, "data": <dict>, "error": ""}`.

## Fixtures
`ok.json` = `{"a": 8, "b": [1, 2]}`; `bad.json` = `{"a": 8,` ; `array_root.json` = `[1, 2]`.
(These tests read files on purpose — the README "no file I/O" rule is waived for the reader's own tests.)

## Tests to write first

1. `test_whole_int` — `8.0 -> 8`, `8 -> 8`, `-3.0 -> -3`, `6.5`, `NAN`, `INF`, `1e12`, `"8"`, `true`, `null` -> null.
2. `test_json_numbers_are_floats_pinned` — `typeof(JSON.parse_string('{"a": 8}')["a"]) == TYPE_FLOAT`.
3. `test_read_ok` — `read_file("res://tests/unit/data/fixtures/ok.json", 1024)`: ok, `whole_int(data["a"]) == 8`.
4. `test_read_missing` — error contains `"not found"`.
5. `test_read_over_cap` — `ok.json` with `max_bytes = 4` -> error contains `"over the cap"`.
6. `test_read_parse_error_has_line` — `bad.json` -> error contains `"line"`.
7. `test_read_array_root` — error contains `"root must be an object"`.

## Run
`-a res://tests/unit/data` (README).

## Done when
README "Done when" + 7 tests green.
