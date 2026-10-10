# CH-041 Plugin bases: ControlVerb + LayoutKind

**Story:** RUL-001
**Goal:** the input-verb and multi-board layout extension points (ADR-0004 table: slot `control.verb`, `layout.kind`).
**Depends:** CH-021 (pattern), CH-032, CH-034, CH-037
**Parallel-safe with:** CH-039, CH-040, CH-042 … CH-050, CH-054
**Files (new):** `src/core/rules/bases/control_verb.gd`, `src/core/rules/bases/layout_kind.gd`, `tests/unit/rules/plugin_bases_verb_test.gd`

## API

```gdscript
@abstract class_name ControlVerb extends RefCounted
## Turns touch gestures into SimCommands and applies them through RuleApi on the tick (ADR-0004). Plugins declare const PLUGIN_ID.
## Gesture dictionary (input -> verb), documented here once (implementation-plan §1.2):
## {kind: &"move"|&"rotate"|&"soft_drop"|&"hard_drop"|&"hold"|&"tap", dir: Vector3i (world, move),
##  axis: int (Orientations.Axis), sign: int (rotate; world axis already resolved by the camera), on: bool (soft_drop), cell: Vector3i (tap)}
@abstract func commands_for(gesture: Dictionary, api: RuleApi) -> Array[SimCommand]
@abstract func apply(cmd: SimCommand, api: RuleApi) -> void
func tags() -> PackedStringArray: return PackedStringArray()
func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]: return []

@abstract class_name LayoutKind extends RefCounted
## Places, links and validates the boards of a level (ADR-0002 §7). Meadow uses `single` only.
@abstract func map_exit(board_id: int, cells: Array[Vector3i], face: Vector3i) -> Dictionary
	## where a piece leaving board_id through face continues: {board_id, cells} or {} for a wall
func tags() -> PackedStringArray: return PackedStringArray()
func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]: return []
```

> The plan's older `LayoutKind.validate(level) -> PackedStringArray` is superseded by gap decision 4 (same signature as every base).

## Tests to write first

1. `test_bases_are_abstract` — `can_instantiate() == false` for both scripts.
2. `test_defaults` — inner subclasses implementing the abstract methods trivially: `tags()` empty, `validate(...)` empty.
3. `test_registry_still_clean` — `PluginRegistry.new(ProjectSettings.get_global_class_list()).errors().is_empty()`.

## Run
`-a res://tests/unit/rules` (README; `--import` first).

## Done when
README "Done when" + 3 tests green.
