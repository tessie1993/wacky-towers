# CH-022 PluginRegistry

**Story:** RUL-001
**Goal:** find plugin scripts by `(kind, PLUGIN_ID)` from the global class list, so a new plugin needs no core edit (ADR-0004 §1).
**Depends:** CH-021
**Parallel-safe with:** every batch-2 ticket except CH-021
**Files:** `src/core/rules/plugin_registry.gd` (new), `tests/unit/rules/plugin_registry_test.gd` (new),
`tests/unit/rules/fixtures/dup_detector.gd` (new, **no** `class_name`)

## API (implementation-plan §1.2)

```gdscript
class_name PluginRegistry extends RefCounted
## Maps plugin kind -> PLUGIN_ID -> Script, built once from ProjectSettings.get_global_class_list() (ADR-0004 §1).

const BASES_DIR := "res://src/core/rules/bases/"   # a "kind" is a class whose script lives here
const ID_CONST := "PLUGIN_ID"

func _init(class_list: Array[Dictionary]) -> void
func create(kind: StringName, plugin_id: StringName) -> RefCounted   ## new instance, or null if unknown
func ids(kind: StringName) -> PackedStringArray                      ## sorted
func errors() -> PackedStringArray
```

**Kind = the base's class name** (`&"ClearDetector"`, `&"RuleBehaviour"`, …). No hardcoded kind list: a new base file in
`BASES_DIR` is a new kind (the plan's "registry needs no change to add them").

Kinds added later (CH-040, CH-041: `GoalEvaluator`, `TopOutPolicy`, `ControlVerb`, `LayoutKind`) are discovered automatically because they live in `BASES_DIR`; do not list kinds anywhere.

## Behaviour

- Index the list by `class` -> entry (`{class, base, path, …}` as `get_global_class_list()` returns).
- For each entry: walk `base` names up through the index until a class whose `path` starts with `BASES_DIR` (that class
  name is the kind) or the chain leaves the index (not a plugin). The base classes themselves are not plugins.
- For a plugin candidate: `load(path)`; `get_script_constant_map()` must have `PLUGIN_ID` of type StringName ->
  else error `"<path>: missing PLUGIN_ID"` / `"<path>: PLUGIN_ID must be a StringName"`, and the class is skipped.
  (Every `class_name` that extends a base is a plugin; there are no intermediate helper classes.)
- Duplicate `(kind, id)` -> error `"duplicate PLUGIN_ID '<id>' for <kind>: <path1>, <path2>"`; first one stays.
- `create`: `_scripts[kind][id].new()`; unknown -> null.

## Fixture `dup_detector.gd` (no `class_name`, so it never enters the real global list)

`extends ClearDetector`, `const PLUGIN_ID: StringName = &"test_only"`, `find_clears` returns `[]`.

## Tests to write first

Helper `_entry(cls, base, path) -> Dictionary` = `{"class": StringName(cls), "base": StringName(base), "path": path}`.
`_list()` = ClearDetector base (`res://src/core/rules/bases/clear_detector.gd`, base `RefCounted`) + TestOnlyDetector fixture.
1. `test_finds_fixture_by_id` — `create(&"ClearDetector", &"test_only")` is a `TestOnlyDetector`; `ids(&"ClearDetector") == ["test_only"]`; no errors.
2. `test_unknown_is_null` — `create(&"ClearDetector", &"nope") == null`; `create(&"Nope", &"test_only") == null`; `ids(&"Nope").is_empty()`.
3. `test_duplicate_id_is_error` — `_list()` + `_entry("DupDetector", "ClearDetector", "res://tests/unit/rules/fixtures/dup_detector.gd")`
   -> 1 error containing `"duplicate PLUGIN_ID 'test_only'"`; `create` still returns a `TestOnlyDetector`.
4. `test_real_global_class_list` — `PluginRegistry.new(ProjectSettings.get_global_class_list())`: `create(&"ClearDetector", &"test_only") != null`,
   `errors().is_empty()` (the real project must have no duplicates).
5. `test_base_is_not_a_plugin` — no kind lists `ClearDetector` itself; `ids(&"RuleBehaviour")` has no entry for the base.

## Run
`-a res://tests/unit/rules` (README; `--import` first so the fixture class is in the global list).

## Done when
README "Done when" + 5 tests green.
