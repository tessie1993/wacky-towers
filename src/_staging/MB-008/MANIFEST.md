# MB-008 manifest
| Final path | Action | See it working |
|---|---|---|
| src/core/model/validation_issue.gd | new | FileSystem dock: class resolves; `ValidationIssue.error(&"a","f",&"r","m")._to_string()` -> "a f: m [r]" |
| src/core/model/goal_state.gd | new | `GoalState.new().result == 0` |
| src/core/sim/sim_command.gd (+ .uid) | delete | core/model/sim_command.gd already holds class SimCommand |
| src/core/sim/sim_event.gd (+ .uid) | delete | core/model/sim_event.gd already holds class SimEvent |

No other src/ file changes: grep shows board_sim.gd and replay.gd use SimCommand/SimEvent by class_name only; no path preloads. Core/model copies lack field doc comments; optionally replace them with the core/sim versions' docs when deleting. ValidationIssue/GoalState had no prior references in src/. Run --import after the delete.

## Review (godot-specialist, 2026-10-10)
- No fixes needed. Both files match CH-148 exactly; GoalState matches CH-151's use (RESULT_* consts).
- CH-043's older GoalState API (progress/target/reached...) is superseded by CH-148/151; do not build MB-016 from CH-043.
- Only path reference into core/sim is tests/unit/sim/sim_types_test.gd -> sim_events.gd (kept), so the deletes are safe.
