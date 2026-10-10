# CH-148 core/model value types: ValidationIssue + GoalState

**Story:** DAT-002 / SIM-004 (pulled forward; gap decisions 4–5 put them in `src/core/model/`)
**Goal:** the two plain value types the plugin bases, validator and sim share.
**Depends:** CH-032 (confirm `SimCommand`/`SimEvent` sit in `src/core/model/`; if not, move them first, `.uid` files included)
**Parallel-safe with:** CH-149, CH-042 … CH-050, CH-054
**Files (new):** `src/core/model/validation_issue.gd`, `src/core/model/goal_state.gd`

## API

```gdscript
class_name ValidationIssue extends RefCounted
## One problem found in level data (ADR-0005). Built by the validator, the loader and plugin validate().
const SEVERITY_ERROR := &"error"
const SEVERITY_WARN := &"warn"
var level_id: StringName = &""
var field: String = ""          # e.g. "board.mask[2]"
var rule: StringName = &""      # short check id, e.g. &"unknown_key", &"out_of_range"
var severity: StringName = SEVERITY_ERROR
var message: String = ""
static func error(level_id: StringName, field: String, rule: StringName, message: String) -> ValidationIssue
static func warn(level_id: StringName, field: String, rule: StringName, message: String) -> ValidationIssue
func is_error() -> bool
func _to_string() -> String     ## "<level_id> <field>: <message> [<rule>]"

class_name GoalState extends RefCounted
## Running goal counters for one board (Level Goals GDD). Plain data; the sim writes it, goal plugins read it.
const RESULT_RUNNING := 0       # same values as GoalEvaluator results (CH-151)
const RESULT_WON := 1
const RESULT_LOST := 2
var layers_cleared: int = 0
var cells_trimmed: int = 0
var warnings_left: int = 0
var level_ms: int = 0
var locks: int = 0
var result: int = RESULT_RUNNING
```

## Expected results (no tests)
User rule 2026-10-10: NO TESTS. Do not write test files. These are the expected results: the integrator checks them in the editor (godot-ai script eval or a scratch script, read with `logs_read`) after moving the file in.

1. `test_issue_factories` — `ValidationIssue.error(&"meadow_01", "board.width", &"out_of_range", "3 outside 4..24")`: fields set, `is_error()`; `warn(...)` -> `is_error() == false`.
2. `test_issue_to_string` — contains `"meadow_01 board.width: 3 outside 4..24 [out_of_range]"`.
3. `test_goal_state_defaults` — all counters 0, `result == RESULT_RUNNING`.

## Run
Integrator: move staged files in, rescan, `logs_read` must show no parse errors or class-name clashes, then check the cases above. No gdUnit run.

## Done when
File(s) in place, editor scan clean, the expected results above hold.

